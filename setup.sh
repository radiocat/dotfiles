#!/bin/bash

# --- Initialization ---
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS_TYPE="$(uname)" # Linux or Darwin
TOTAL_STEPS=6 # Total number of main setup steps

echo "Starting dotfiles setup for $OS_TYPE..."

# --- Helper function for creating symlinks ---
# Handles existing files/directories by backing them up, and creates parent directories.
function create_symlink {
    local target="$1"
    local link="$2"

    # Check if target exists
    if [ ! -e "$target" ]; then
        echo "Skip: Target not found [$target]." >&2
        return 1
    fi

    # Create parent directory if it doesn't exist
    local parent_dir=$(dirname "$link")
    if [ ! -d "$parent_dir" ]; then
        mkdir -p "$parent_dir"
        echo "Created directory: $parent_dir"
    fi

    if [ -L "$link" ]; then
        # If it's already a symlink, skip if pointing to the same target
        if [ "$(readlink "$link")" == "$target" ]; then
            echo "Skip: Link already exists and points to target [$link]" >&2
            return 0
        fi
        # If it's a symlink but pointing elsewhere, remove and re-link
        rm "$link"
        echo "Removed existing symlink: $link"
    elif [ -e "$link" ]; then
        # If it's a regular file or directory, back it up
        local backup="${link}.bak.$(date +%Y%m%d%H%M%S)"
        mv "$link" "$backup"
        echo "Backup created: $link -> $backup" >&2
    fi

    # Create the new symlink
    ln -sfn "$target" "$link"
    echo "Linked: $link -> $target"
}

# --- [1/$TOTAL_STEPS] Updating package manager and installing core tools ---
echo "
[1/$TOTAL_STEPS] Updating package manager and installing core tools..."

# Install zsh if not present (Linux only)
if [ "$OS_TYPE" == "Linux" ]; then
    if ! command -v zsh &> /dev/null; then
        echo "Installing zsh via apt..."
        sudo apt update && sudo apt install -y zsh
    fi
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Evaluate Homebrew environment variables
    if [ "$OS_TYPE" == "Linux" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ "$OS_TYPE" == "Darwin" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed. Updating..."
    brew update
fi

# Install packages from Brewfile
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo "Installing common tools from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"

    if [ "$OS_TYPE" == "Darwin" ]; then
        echo "macOS detected. Installing GUI applications from Brewfile.macos..."
        if [ -f "$DOTFILES_DIR/Brewfile.macos" ]; then
            brew bundle --file="$DOTFILES_DIR/Brewfile.macos"
        fi
    else
        echo "Linux/WSL2 detected. Skipping macOS GUI applications."
    fi
else
    echo "Warning: Brewfile not found at $DOTFILES_DIR/Brewfile. Skipping Homebrew bundle install." >&2
fi

# fzf post-installation setup
if command -v fzf &> /dev/null; then
    echo "Running fzf post-installation setup..."
    "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
else
    echo "Skip: fzf not found. Skipping fzf post-installation setup." >&2
fi

# --- [2/$TOTAL_STEPS] Preparing directories ---
echo "
[2/$TOTAL_STEPS] Preparing directories..."

mkdir -p "$HOME/.config"

# --- [3/$TOTAL_STEPS] Creating symlinks for configuration files ---
echo "
[3/$TOTAL_STEPS] Creating symlinks for configuration files..."

create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/.editorconfig" "$HOME/.editorconfig"
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
create_symlink "$HOME/.vim" "$HOME/vimfiles" # For older Vim compatibility

# --- [4/$TOTAL_STEPS] Setting up Python virtual environment and AI libraries ---
echo "
[4/$TOTAL_STEPS] Setting up Python virtual environment and AI libraries..."

VENV_DIR="$DOTFILES_DIR/.venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment at $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
else
    echo "Python virtual environment already exists at $VENV_DIR."
fi

# Activate venv and install/upgrade Python packages
if [ -f "$VENV_DIR/bin/pip" ]; then
    echo "Upgrading pip..."
    "$VENV_DIR/bin/pip" install --upgrade pip
    echo "Installing/Upgrading google-genai..."
    "$VENV_DIR/bin/pip" install --upgrade google-genai
    
    # Aiderのインストール処理を追加
    echo "Installing/Upgrading aider-chat..."
    "$VENV_DIR/bin/pip" install --upgrade aider-chat
    
    echo "Python libraries updated successfully."    
else
    echo "Error: pip not found in virtual environment. Please check Python venv setup." >&2
fi

# --- [5/$TOTAL_STEPS] Installing Official Gemini CLI ---
echo "
[5/$TOTAL_STEPS] Installing Official Gemini CLI..."
if command -v npm &> /dev/null; then
    echo "Installing @google/gemini-cli globally via npm..."
    npm install -g @google/gemini-cli
else
    echo "⚠️ npm is not found. Please check your Homebrew installation."
fi

# --- Anthropic Claude CLIのインストール ---
echo "Installing Anthropic Claude CLI..."
if command -v npm &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
else
    echo "⚠️ npm is not found. Please check your Homebrew installation."
fi

# --- [6/$TOTAL_STEPS] Creating local configuration files ---
echo "
[6/$TOTAL_STEPS] Creating local configuration files (if not exist)..."

if [ ! -f "$DOTFILES_DIR/.env.local" ]; then
    cp "$DOTFILES_DIR/.env.local.example" "$DOTFILES_DIR/.env.local"
    echo "Created .env.local. Please fill in your Gemini API Key."
else
    echo ".env.local already exists. Skipping creation."
fi

if [ ! -f "$HOME/.gitconfig.local" ]; then
    cp "$DOTFILES_DIR/git/.gitconfig.local" "$HOME/.gitconfig.local"
    echo "Created .gitconfig.local. Please fill in your Git credentials."
else
    echo ".gitconfig.local already exists. Skipping creation."
fi

# --- Finalization ---
echo "
=== Dotfiles Setup Completed! ==="

CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "Please switch your default shell to zsh:"
    echo "  chsh -s \$(which zsh)"
    echo "Then restart your terminal to apply changes."
else
    echo "Please restart your shell to apply changes."
fi

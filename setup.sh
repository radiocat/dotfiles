#!/bin/bash

# dotfilesのディレクトリパスを取得
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# OSの判定
OS_TYPE="$(uname)" # Linux or Darwin

echo "Starting setup for $OS_TYPE..."

# zsh の存在確認とインストール (Linux の場合)
if [ "$OS_TYPE" == "Linux" ]; then
    if ! command -v zsh &> /dev/null; then
        echo "🐚 zsh not found. Installing via apt..."
        sudo apt update && sudo apt install -y zsh
    fi
fi

# Homebrewのインストール (Linux/Mac共通)
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # WSL2の場合はパスを通す処理が必要
    if [ "$OS_TYPE" == "Linux" ]; then
        test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
        test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ "$OS_TYPE" == "Darwin" ]; then
        test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Brewfileによるパッケージの一括インストール
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

# シンボリックリンクの作成
echo "Creating symlinks..."
ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# Starship設定のリンク
mkdir -p "$HOME/.config"
ln -sfv "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# fzfのセットアップ
if command -v fzf &> /dev/null; then
    $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
fi

# scriptsへの実行権限付与
chmod +x "$DOTFILES_DIR/scripts/"*.py

# --- Python venv と AIライブラリのセットアップ ---
echo "Setting up Python virtual environment..."
# デフォルトの .venv を作成
if [ ! -d "$DOTFILES_DIR/.venv" ]; then
    python3 -m venv "$DOTFILES_DIR/.venv"
fi
# システム環境を汚染しないよう、仮想環境内の pip を使用してインストール
"$DOTFILES_DIR/.venv/bin/pip" install --upgrade pip
"$DOTFILES_DIR/.venv/bin/pip" install --upgrade google-genai

# --- 公式Gemini CLIのインストール ---
echo "Installing Official Gemini CLI..."
# Brewfileでインストールされたnpmを使ってグローバルインストール
if command -v npm &> /dev/null; then
    npm install -g @google/gemini-cli
else
    echo "⚠️ npm is not found. Please check your Homebrew installation."
fi

# 秘匿情報ファイルの作成（存在しない場合のみ）
if [ ! -f "$DOTFILES_DIR/.env.local" ]; then
    cp "$DOTFILES_DIR/.env.local.example" "$DOTFILES_DIR/.env.local"
    echo "Created .env.local. Please fill in your Gemini API Key."
fi

if [ ! -f "$HOME/.gitconfig.local" ]; then
    cp "$DOTFILES_DIR/git/.gitconfig.local" "$HOME/.gitconfig.local"
    echo "Created .gitconfig.local. Please fill in your Git credentials."
fi

# デフォルトシェルの変更案内
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "⚠️  Your current shell is $CURRENT_SHELL."
    echo "Please run: chsh -s \$(which zsh)"
fi

echo "Setup completed! Please restart your shell."

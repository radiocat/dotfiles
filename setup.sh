#!/bin/bash

# dotfilesのディレクトリパスを取得
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# OSの判定
OS_TYPE="$(uname)" # Linux or Darwin

echo "Starting setup for $OS_TYPE..."

# Homebrewのインストール (Linux/Mac共通)
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # WSL2の場合はパスを通す処理が必要
    if [ "$OS_TYPE" == "Linux" ]; then
        test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
        test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi

# Oh My Zsh のインストール 
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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

# scriptsへの実行権限付与
chmod +x "$DOTFILES_DIR/scripts/"*.py

# 秘匿情報ファイルの作成（存在しない場合のみ）
if [ ! -f "$DOTFILES_DIR/.env.local" ]; then
    cp "$DOTFILES_DIR/.env.local.example" "$DOTFILES_DIR/.env.local"
    echo "Created .env.local. Please fill in your Gemini API Key."
fi

if [ ! -f "$HOME/.gitconfig.local" ]; then
    cp "$DOTFILES_DIR/git/.gitconfig.local" "$HOME/.gitconfig.local"
    echo "Created .gitconfig.local. Please fill in your Git credentials."
fi

echo "Setup completed! Please restart your shell."

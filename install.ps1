<#
.SYNOPSIS
    Windows環境構築用セットアップスクリプト
.DESCRIPTION
    Wingetを使ったツールのインストールと設定ファイルのシンボリックリンク作成を行います。
    管理者権限で実行してください。
#>

# エラーが発生したら停止
$ErrorActionPreference = "Stop"

# --- 1. 管理者権限チェック ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "このスクリプトは管理者権限で実行する必要があります。"
    Write-Warning "PowerShellを「管理者として実行」してからやり直してください。"
    exit 1
}

Write-Host "=== Windows Environment Setup Started ===" -ForegroundColor Cyan

# --- Wingetソースの更新 ---
Write-Host "`n[0/4] Updating Winget Sources..." -ForegroundColor Green
try {
    winget source update
} catch {
    Write-Warning "Winget source update failed. Continuing anyway..."
}

# --- 2. モダンツールのインストール (Winget) ---
Write-Host "`n[1/4] Installing Modern Tools via Winget..." -ForegroundColor Green

# インストールするパッケージリスト
$packages = @(
    # Core Tools
    @{Id = "Microsoft.PowerShell"; Name = "PowerShell 7"},
    @{Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal"},
    @{Id = "Neovim.Neovim"; Name = "Neovim (Modern Vim)"},
    @{Id = "Starship.Starship"; Name = "Starship (Prompt)"},
    
    # Dev Tools
    @{Id = "GitHub.cli"; Name = "GitHub CLI"},
    @{Id = "Python.Python.3"; Name = "Python 3"},
    @{Id = "JFLarvoire.Ag"; Name = "The Silver Searcher (ag)"},
    @{Id = "BurntSushi.RipGrep.MSVC"; Name = "Ripgrep (rg)"},
    @{Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code"},
    @{Id = "OpenJS.NodeJS"; Name = "Node.js"},

    # Applications
    @{Id = "Google.Chrome"; Name = "Google Chrome"},
    @{Id = "Google.JapaneseIME"; Name = "Google Japanese Input"},
    @{Id = "Obsidian.Obsidian"; Name = "Obsidian"}
)

foreach ($pkg in $packages) {
    Write-Host "Installing $($pkg.Name)..."
    try {
        # 既にインストール済みかチェックしつつインストール/アップグレード
        winget install --id $pkg.Id -e --source winget --accept-package-agreements --accept-source-agreements
    }
    catch {
        Write-Warning "Failed to install $($pkg.Name). You may need to install it manually."
    }
}

# --- 3. ディレクトリ構造の準備 ---
Write-Host "`n[2/4] Preparing Directories..." -ForegroundColor Green

$dotfilesDir = "$HOME\dotfiles"
$configDir = "$HOME\AppData\Local"

# Neovim用設定ディレクトリ
$nvimDir = "$configDir\nvim"
if (!(Test-Path $nvimDir)) {
    New-Item -ItemType Directory -Path $nvimDir -Force | Out-Null
    Write-Host "Created: $nvimDir"
}

# --- 4. シンボリックリンクの作成 ---
Write-Host "`n[3/4] Linking Configuration Files for Neovim..." -ForegroundColor Green

# Neovim (Modern)
# Windowsでは ~/AppData/Local/nvim に設定を置く
$nvimTargetDir = "$HOME\AppData\Local\nvim"

if (Test-Path $nvimTargetDir) {
    # 既存のディレクトリがある場合はバックアップ
    $backupNvim = "$nvimTargetDir.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Rename-Item -Path $nvimTargetDir -NewName $backupNvim
}

# dotfiles/nvim を直接 AppData/Local/nvim にリンク
New-SymLink -Target "$dotfilesDir\nvim" -Link $nvimTargetDir

# --- 5. Pythonライブラリのセットアップ (AI活用用) ---
Write-Host "`n[4/4] Setting up Python Libraries for AI..." -ForegroundColor Green
try {
    # pipのアップグレード
    python -m pip install --upgrade pip
    
    # 旧ライブラリの削除と新ライブラリ(google-genai)のインストール
    Write-Host "Installing/Updating google-genai package..."
    python -m pip uninstall -y google-generativeai
    python -m pip install --upgrade google-genai
    
    Write-Host "Python libraries installed successfully."
}
catch {
    Write-Warning "Failed to install Python libraries. Please run 'pip install google-genai' manually."
}

Write-Host "`n=== Setup Completed! ===" -ForegroundColor Cyan

# --- リンク定義 ---

# 既存のリンク定義に .editorconfig を追加
New-SymLink -Target "$dotfilesDir\.editorconfig" -Link "$HOME\.editorconfig"

# 1. .gitconfig (共通)
New-SymLink -Target "$dotfilesDir\.gitconfig" -Link "$HOME\.gitconfig"

# 1. .gitconfig (共通)
New-SymLink -Target "$dotfilesDir\.gitconfig" -Link "$HOME\.gitconfig"

# 2. Vim (Classic)
New-SymLink -Target "$dotfilesDir\vim\vimrc" -Link "$HOME\.vimrc"
New-SymLink -Target "$dotfilesDir\vim\gvimrc" -Link "$HOME\.gvimrc"

# .vim ディレクトリの準備
$vimDir = "$HOME\.vim"
if (!(Test-Path $vimDir)) {
    New-Item -ItemType Directory -Path $vimDir -Force | Out-Null
    Write-Host "Created: $vimDir"
}
New-SymLink -Target "$HOME\.vim" -Link "$HOME\vimfiles"

# 3. Neovim (Modern)
$initVimContent = "set runtimepath^=~/.vim runtimepath+=~/.vim/after`nlet &packpath = &runtimepath`nsource ~/.vimrc"
$initVimPath = "$nvimDir\init.vim"
if (!(Test-Path $initVimPath)) {
    Set-Content -Path $initVimPath -Value $initVimContent
    Write-Host "Created: Neovim compatibility shim at $initVimPath" -ForegroundColor Cyan
}

# 4. PowerShell Profile
$repoProfile = "$dotfilesDir\windows\Microsoft.PowerShell_profile.ps1"
$targetProfile = $PROFILE.CurrentUserAllHosts
$psProfileDir = Split-Path $targetProfile -Parent

if (!(Test-Path $psProfileDir)) {
    New-Item -ItemType Directory -Path $psProfileDir -Force | Out-Null
    Write-Host "Created: $psProfileDir"
}

if (Test-Path $repoProfile) {
    New-SymLink -Target $repoProfile -Link $targetProfile
} else {
    Write-Warning "PowerShell profile not found in dotfiles. Skipping link."
}

# --- 5. 公式Gemini CLIのインストール ---
Write-Host "`n[5/5] Installing Official Gemini CLI..." -ForegroundColor Green
try {
    # npmを使ってグローバルにインストール
    npm install -g @google/gemini-cli
    Write-Host "Official Gemini CLI installed successfully."
}
catch {
    Write-Warning "Failed to install Official Gemini CLI. Please run 'npm install -g @google/gemini-cli' manually after restarting the terminal."
}

Write-Host "`n=== Setup Completed! ===" -ForegroundColor Cyan
Write-Host "Please restart your terminal to apply changes."
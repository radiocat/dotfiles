<#
.SYNOPSIS
    Windows環境構築用セットアップスクリプト
.DESCRIPTION
    Winget/NPM/Pipを使用したツールのインストールと、設定ファイルのシンボリックリンク作成を一括で行います。
    管理者権限で実行してください。
#>

# エラー発生時に停止
$ErrorActionPreference = "Stop"

# --- 1. 管理者権限チェック ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "このスクリプトは管理者権限で実行する必要があります。"
    Write-Warning "PowerShellを「管理者として実行」してから再度実行してください。"
    exit 1
}

# --- 2. ヘルパー関数 ---

# シンボリックリンク作成用 (バックアップ機能付き)
function New-SymLink {
    param (
        [Parameter(Mandatory=$true)][string]$Target, # リンク先（実体）
        [Parameter(Mandatory=$true)][string]$Link    # リンクの作成場所
    )

    if (Test-Path $Link) {
        $item = Get-Item $Link
        # 既にシンボリックリンク（またはジャンクション）の場合はスキップ
        if ($item.Attributes -match "ReparsePoint") {
            Write-Host "Skip: Link already exists [$Link]" -ForegroundColor Gray
            return
        } else {
            # 実体（ファイル/ディレクトリ）がある場合はバックアップ
            $backup = "$Link.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Rename-Item -Path $Link -NewName $backup
            Write-Warning "Backup created: $Link -> $backup"
        }
    }

    # 親ディレクトリがない場合は作成
    $parentDir = Split-Path $Link -Parent
    if (!(Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    # 実体（ターゲット）が存在するかチェック
    if (!(Test-Path $Target)) {
        Write-Warning "Target not found: $Target. Skipping link creation."
        return
    }

    # シンボリックリンク作成
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
    Write-Host "Linked: $Link -> $Target" -ForegroundColor Cyan
}

# --- 3. 初期設定 ---
Write-Host "=== Windows Environment Setup Started ===" -ForegroundColor Cyan

$dotfilesDir = "$HOME\dotfiles"
$configDir = "$HOME\AppData\Local"
$totalSteps = 5

# --- [1/5] モダンツールのインストール (Winget) ---
Write-Host "`n[1/$totalSteps] Updating Winget and Installing Tools..." -ForegroundColor Green
try {
    winget source update
} catch {
    Write-Warning "Winget source update failed. Continuing..."
}

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
        winget install --id $pkg.Id -e --source winget --accept-package-agreements --accept-source-agreements
    } catch {
        Write-Warning "Failed to install $($pkg.Name). You may need to install it manually."
    }
}

# --- [2/5] Pythonライブラリのセットアップ ---
Write-Host "`n[2/$totalSteps] Setting up Python Libraries for AI..." -ForegroundColor Green
try {
    python -m pip install --upgrade pip
    Write-Host "Installing/Updating google-genai package..."
    python -m pip uninstall -y google-generativeai
    python -m pip install --upgrade google-genai
    Write-Host "Python libraries updated successfully."
} catch {
    Write-Warning "Failed to setup Python libraries. Run 'pip install google-genai' manually."
}

# --- [3/5] 公式Gemini CLIのインストール ---
Write-Host "`n[3/$totalSteps] Installing Official Gemini CLI via NPM..." -ForegroundColor Green
try {
    npm install -g @google/gemini-cli
    Write-Host "Official Gemini CLI installed successfully."
} catch {
    Write-Warning "Failed to install @google/gemini-cli. Run 'npm install -g @google/gemini-cli' manually."
}

# --- [4/5] ディレクトリ構造の準備 ---
Write-Host "`n[4/$totalSteps] Preparing Directories..." -ForegroundColor Green
$dirs = @(
    "$configDir\nvim",
    "$HOME\.vim"
)
foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created: $dir"
    }
}

# --- [5/5] シンボリックリンクの作成 ---
Write-Host "`n[5/$totalSteps] Linking Configuration Files..." -ForegroundColor Green

# 1. Neovim (AppData/Local/nvim -> dotfiles/nvim)
New-SymLink -Target "$dotfilesDir\nvim" -Link "$configDir\nvim"

# 2. Git & EditorConfig
New-SymLink -Target "$dotfilesDir\git\.gitconfig" -Link "$HOME\.gitconfig"
New-SymLink -Target "$dotfilesDir\.editorconfig" -Link "$HOME\.editorconfig"

# 3. Vim (Classic)
New-SymLink -Target "$dotfilesDir\vim\vimrc" -Link "$HOME\.vimrc"
New-SymLink -Target "$dotfilesDir\vim\gvimrc" -Link "$HOME\.gvimrc"
New-SymLink -Target "$HOME\.vim" -Link "$HOME\vimfiles"

# 4. Neovim 互換性設定 (init.vim がない場合のみ作成)
$initVimPath = "$configDir\nvim\init.vim"
if (!(Test-Path $initVimPath)) {
    $initVimContent = "set runtimepath^=~/.vim runtimepath+=~/.vim/after`nlet &packpath = &runtimepath`nsource ~/.vimrc"
    Set-Content -Path $initVimPath -Value $initVimContent
    Write-Host "Created: Neovim compatibility shim at $initVimPath" -ForegroundColor Cyan
}

# 5. PowerShell Profile
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

# --- Anthropic Claude CLIのインストール ---
Write-Host "`nInstalling Anthropic Claude CLI..." -ForegroundColor Green
try {
    npm install -g @anthropic-ai/claude-code
    Write-Host "Anthropic Claude CLI installed successfully."
}
catch {
    Write-Warning "Failed to install Anthropic Claude CLI. Please run 'npm install -g @anthropic-ai/claude-code' manually after restarting the terminal."
}

Write-Host "`n=== Setup Completed! ===" -ForegroundColor Cyan
Write-Host "変更を反映するため、ターミナルを再起動してください。"
Write-Host "Google API Keyの設定を忘れずに行ってください。"

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

# --- 2. モダンツールのインストール (Winget) ---
Write-Host "`n[1/3] Installing Modern Tools via Winget..." -ForegroundColor Green

# インストールするパッケージリスト
# IDは変更される可能性があるため、必要に応じて `winget search` で確認してください
$packages = @(
    # Core Tools
    @{Id = "Microsoft.PowerShell"; Name = "PowerShell 7"},
    @{Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal"},
    @{Id = "Neovim.Neovim"; Name = "Neovim (Modern Vim)"},
    @{Id = "Starship.Starship"; Name = "Starship (Prompt)"},
    
    # Dev Tools
    @{Id = "GitHub.cli"; Name = "GitHub CLI"},
    @{Id = "Python.Python.3"; Name = "Python 3"},
    @{Id = "Ag.Ag"; Name = "The Silver Searcher (ag)"}, 
    @{Id = "BurntSushi.RipGrep.MSVC"; Name = "Ripgrep (rg)"},
    @{Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code"},

    # Applications
    @{Id = "Google.Chrome"; Name = "Google Chrome"},
    @{Id = "Google.JapaneseIME"; Name = "Google Japanese Input"}
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
Write-Host "`n[2/3] Preparing Directories..." -ForegroundColor Green

$dotfilesDir = "$HOME\dotfiles"
$configDir = "$HOME\AppData\Local"

# Neovim用設定ディレクトリ
$nvimDir = "$configDir\nvim"
if (!(Test-Path $nvimDir)) {
    New-Item -ItemType Directory -Path $nvimDir -Force | Out-Null
    Write-Host "Created: $nvimDir"
}

# --- 4. シンボリックリンクの作成 ---
Write-Host "`n[3/3] Linking Configuration Files..." -ForegroundColor Green

# リンク作成用ヘルパー関数
function New-SymLink {
    param (
        [string]$Target, # リンク先（実体）
        [string]$Link    # リンクの作成場所
    )

    if (Test-Path $Link) {
        # 既にファイル/フォルダが存在する場合
        $item = Get-Item $Link
        if ($item.LinkType -eq "SymbolicLink") {
            Write-Host "Skip: Link already exists [$Link]" -ForegroundColor Gray
            return
        } else {
            # 実ファイルがある場合はバックアップを作成
            $backup = "$Link.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Rename-Item -Path $Link -NewName $backup
            Write-Warning "Backup created: $Link -> $backup"
        }
    }

    # シンボリックリンク作成
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
    Write-Host "Linked: $Link -> $Target" -ForegroundColor Cyan
}

# --- リンク定義 ---

# 1. .gitconfig (共通)
New-SymLink -Target "$dotfilesDir\.gitconfig" -Link "$HOME\.gitconfig"

# 2. Vim (Classic)
New-SymLink -Target "$dotfilesDir\vim\vimrc" -Link "$HOME\.vimrc"
New-SymLink -Target "$dotfilesDir\vim\gvimrc" -Link "$HOME\.gvimrc"
# .vim ディレクトリのリンク (プラグイン等)
# 注意: Windowsでは $HOME\vimfiles が標準だが、.vim も認識される場合が多い
New-SymLink -Target "$dotfilesDir\.vim" -Link "$HOME\.vim" 
# setup.bat にあった vimfiles へのリンクも維持
New-SymLink -Target "$HOME\.vim" -Link "$HOME\vimfiles"

# 3. Neovim (Modern)
# 既存の vimrc を Neovim の init.vim として読み込ませることで設定を共有
# 将来的には init.lua へ移行推奨ですが、まずは既存資産を活かします
$initVimContent = "set runtimepath^=~/.vim runtimepath+=~/.vim/after`nlet &packpath = &runtimepath`nsource ~/.vimrc"
$initVimPath = "$nvimDir\init.vim"
if (!(Test-Path $initVimPath)) {
    Set-Content -Path $initVimPath -Value $initVimContent
    Write-Host "Created: Neovim compatibility shim at $initVimPath" -ForegroundColor Cyan
}

# 4. PowerShell Profile (新規作成する場合)
# リポジトリ内にまだファイルがないため、存在確認してからリンクします
# $PROFILE 変数から正しいパス（CurrentUserAllHostsなど）を取得
# 通常は ...\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 です
$targetProfile = $PROFILE.CurrentUserAllHosts
$psProfileDir = Split-Path $targetProfile -Parent

# ディレクトリがなければ作成
if (!(Test-Path $psProfileDir)) {
    New-Item -ItemType Directory -Path $psProfileDir -Force | Out-Null
    Write-Host "Created: $psProfileDir"
}

if (Test-Path $repoProfile) {
    New-SymLink -Target $repoProfile -Link $targetProfile
} else {
    Write-Warning "PowerShell profile not found in dotfiles. Skipping link."
    Write-Warning "Planned path: $repoProfile"
}

Write-Host "`n=== Setup Completed! ===" -ForegroundColor Cyan
Write-Host "Please restart your terminal to apply changes."
Write-Host "Note: Google Japanese Input may require a system restart to activate."

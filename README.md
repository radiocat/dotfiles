# dotfiles

----

Windows, macOS, Linux 環境のセットアップ用設定ファイル群です。
AI活用（Gemini CLI）と Obsidian による情報管理を統合したモダンな開発環境を構築します。

## 🪟 Windows 環境のセットアップ

Windows 10 / 11 対応。PowerShell 7, Neovim, Starship, Obsidian, Gemini CLI を一括でセットアップします。

### 1. 前提条件

* **管理者権限** で PowerShell を実行できること
* インターネット接続

### 2. インストール手順

まず、Git をインストールし、リポジトリをクローンしてインストーラーを実行します。
以下のコマンドブロックを **管理者権限の PowerShell** に貼り付けて実行してください。

```powershell
# 1. (Gitが入っていない場合) Gitをインストール
winget install --id Git.Git -e --source winget

# 2. ホームディレクトリへ移動
cd $HOME

# 3. リポジトリをクローン
git clone https://github.com/radiocat/dotfiles.git

# 4. セットアップスクリプトを実行
# (スクリプト実行ポリシーを一時的に許可して実行します)
Set-ExecutionPolicy RemoteSigned -Scope Process -Force; ./dotfiles/install.ps1

```

### 3. インストールされるもの

`install.ps1` は Winget を使用して以下をインストールします。

* **Core:** PowerShell 7, Windows Terminal, Starship (Prompt)
* **Editor:** Neovim (with `.vimrc` compatibility), VSCode
* **Dev Tools:** Git, GitHub CLI, Python 3, Ag, Ripgrep
* **Apps:** Google Chrome, Google日本語入力, Obsidian
* **Libraries:** `google-generativeai` (for Gemini CLI)

### 4. AI機能 (Gemini CLI) の有効化

インストール後、コマンドラインから Google Gemini を利用するために API キーの設定が必要です。

1. [Google AI Studio](https://aistudio.google.com/app/apikey) で API キーを取得してください。
2. 以下のコマンドで環境変数を設定します（PowerShellで実行）。

```powershell
[System.Environment]::SetEnvironmentVariable('GOOGLE_API_KEY', 'ここに取得したAPIキーを入力', 'User')

```

3. 設定を反映するため、**ターミナルを再起動**してください。

---

## 🤖 AI機能の使い方

`gemini` コマンドで、ターミナルから直接 AI に質問したり、テキスト処理を行えます。

### 基本的な使い方

```powershell
gemini "PowerShellで空のファイルを作成するコマンドは？"

```

### Obsidian との連携（応用）

標準入力（パイプ）を使って、ファイルの内容を要約したり、Obsidian のノートとして保存したりできます。

```powershell
# 議事録を要約して Obsidian の Inbox に保存する
Get-Content ./meeting_log.txt | gemini "この議事録のToDoを抽出してMarkdownリストにして" >> "$HOME\Documents\ObsidianVault\Inbox\ToDo.md"

# クリップボードの内容を校正する
Get-Clipboard | gemini "この文章をビジネスメールとして適切な敬語に直して"

```

---

## 🍎 macOS / 🐧 Linux 環境のセットアップ

従来の手順も利用可能です。

```bash
cd ~
git clone https://github.com/radiocat/dotfiles.git
cd dotfiles
./setup.sh

```

---

## 📁 ディレクトリ構成

* `windows/`: Windows 用設定ファイル (PowerShell プロファイル等)
* `scripts/`: クロスプラットフォーム用スクリプト (Gemini CLI 等)
* `vim/`: Vim / Neovim 共通設定
* `zsh/`, `bash/`: シェル設定 (Mac/Linux用)
* `install.ps1`: Windows 用インストーラー
* `setup.sh`: Mac/Linux 用インストーラー

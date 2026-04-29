# dotfiles

----

Windows, macOS, Linux 環境のセットアップ用設定ファイル群です。
AI活用（Gemini CLI）と Obsidian による情報管理を統合したモダンな開発環境を構築します。

## 🪟 Windows 環境のセットアップ（Powershell）

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
git clone [https://github.com/radiocat/dotfiles.git](https://github.com/radiocat/dotfiles.git)

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

自作の `genai` コマンドでパイプライン処理を、公式の `gemini` コマンドで対話型AIを利用できます。

### 基本的な使い方 (自作ツール)

```powershell
genai "PowerShellで空のファイルを作成するコマンドは？"
```

### Obsidian との連携（応用）

標準入力（パイプ）を使って、ファイルの内容を要約したり、Obsidian のノートとして保存したりできます。

```powershell
# 議事録を要約して Obsidian の Inbox に保存する
Get-Content ./meeting_log.txt | genai "この議事録のToDoを抽出してMarkdownリストにして" >> "$HOME\Documents\ObsidianVault\Inbox\ToDo.md"

# クリップボードの内容を校正する
Get-Clipboard | genai "この文章をビジネスメールとして適切な敬語に直して"

```

---

## 🍎 macOS / 🐧 Linux 環境のセットアップ

従来の手順も利用可能です。

```bash
cd ~
git clone [https://github.com/radiocat/dotfiles.git](https://github.com/radiocat/dotfiles.git)
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



---

# EM-Ops: Dotfiles for Modern Technical Orchestrator

エンジニアリングマネージャー（EM）の業務をエンジニアリング視点でハックし、生産性を最大化するための設定ファイル群です。
Windows (WSL2), macOS, Chromebook のマルチプラットフォームに対応し、AIエージェントとObsidianを統合した「第二の脳」を構築します。

## 💡 コンセプト：EM-Ops
- **Logic vs. Data:** マネジメントの「型（プロンプトやスクリプト）」をコード管理し、機密データと完全に分離。
- **AI-Driven Management:** Gemini CLIやMCPサーバーを活用し、1on1準備やドキュメント作成を自動化。
- **Obsidian Connectivity:** ローカルの知識ベースをAIに接続し、構造化された意思決定を支援。

---


## 🪟 Windows (WSL2) での準備手順

まずはLinuxサブシステム（WSL2）を有効化し、その中でこのdotfilesを展開します。

### 1. WSL2 のインストール

**管理者権限の PowerShell** を開き、以下のコマンドを実行してください。

```powershell
# WSL2とUbuntu(デフォルト)のインストール
wsl --install
```

※ 実行後、OSの再起動が必要です。再起動後、Ubuntuのターミナルが立ち上がり、ユーザー名とパスワードの設定を求められます。

### 2. WSL2 内での Git 設定

WSL2のターミナル（Ubuntu）が起動したら、Linux側でリポジトリを管理するために Git を準備します。

```bash
sudo apt update && sudo apt install -y git
```

### 3. リポジトリのクローンと実行

**重要:** パフォーマンスと権限の問題を避けるため、Windows側（`/mnt/c/`）ではなく、**WSL2のホームディレクトリ（`~/`）直下**にクローンしてください。

```bash
cd $HOME
git clone https://github.com/radiocat/dotfiles.git
cd dotfiles
chmod +x setup.sh
./setup.sh
```

### 4. Windows側の Obsidian Vault との紐付け

WSL2上のAIツールからWindows側のObsidianノートを読み書きできるよう、パスを設定します。

1. `dotfiles/.env.local` を作成（`setup.sh` で自動作成されているはずです）。
2. `OBSIDIAN_VAULT_PATH` を、WindowsのパスをWSL2形式に変換して記述します。

```bash
# 例: Windowsの C:\Users\name\Documents\Vault の場合
export OBSIDIAN_VAULT_PATH="/mnt/c/Users/yourname/Documents/ObsidianVault"
```

---

## 🛠️ トラブルシューティング & Tips

### WSL2からWindowsのObsidianを快適に開く

`.zshrc` に設定されたエイリアスにより、WSL2ターミナルから `obsidian` と打つだけでWindows側のアプリを起動できるように調整可能です（※パスの調整が必要）。

### ファイルシステムの違いに注意

- **設定ファイル(dotfiles):** WSL2の `~/` 直下で管理（爆速・安定）。
- **業務ドキュメント(Obsidian):** Windows側のフォルダで管理（iCloud/Google Drive同期やGUIアプリとの親和性）。
AI（Gemini CLI）はこの2つの世界を `/mnt/c/` 経由で繋ぎます。

---

## 🚀 クイックスタート (WSL2 / macOS 共通)

Windowsユーザーも、今後は **WSL2 (Ubuntu等)** 上での運用を推奨します。MacBook支給後も同じ手順で環境再現が可能です。

### 1. 前提条件
- Git がインストールされていること
- WSL2 (Windowsの場合) または Homebrew (Macの場合)

### 2. セットアップ手順
ターミナルを開き、以下のコマンドを実行してください。

```bash
# 1. ホームディレクトリへ移動してクローン
cd $HOME
git clone https://github.com/radiocat/dotfiles.git

# 2. セットアップスクリプトの実行
cd dotfiles
chmod +x setup.sh
./setup.sh
```

`setup.sh` は内部で **Homebrew** を使用し、`Brewfile` に定義された必須ツール（zsh, fzf, ripgrep, gh, python 等）を一括インストールします。

---

## ⚙️ プラットフォーム別設定

### 🪟 Windows (WSL2)
Windows側の Obsidian Vault にアクセスするため、`.env.local` にマウントパスを設定します。

```bash
# .env.local の例
export OBSIDIAN_VAULT_PATH="/mnt/c/Users/yourname/Documents/ObsidianVault"
```

### 🍎 macOS
支給されたMacBookでは、`setup.sh` を実行するだけでWSL2と全く同じエイリアス、AIスクリプトが利用可能になります。

---

## 🤖 EM-Ops 機能の使い方

### 1. AIエージェント (`genai.py`)
標準入力や引数からAI（Gemini 1.5 Pro等）を呼び出します。Vault内の `AGENTS.md` を参照し、その内容に基づいた回答を生成します。

```bash
# 1on1の生メモからネクストアクションを抽出
cat meeting_notes.md | genai "このメモからToDoを抽出して"

# 技術記事の要約
genai "以下のURLの内容を3行で要約して: [URL]"
```

### 2. Obsidian 連携
`fzf` と `ripgrep` を組み合わせ、ターミナルからノートを高速検索・編集するワークフローを提供します。

---

## 📁 ディレクトリ構成

* `scripts/`: EM業務を自動化する AI/Python スクリプト群 (EM-Skills)
* `zsh/`: macOS/WSL2 共通のシェル設定
* `vim/`: エディタ共通設定
* `Brewfile`: ツール一括管理シート
* `.env.local.example`: 環境変数のテンプレート（Git管理外の `.env.local` を作成して使用）

---

## 🛠️ カスタマイズ
個人固有の設定やAPIキーは、Git管理から除外される `.env.local` および `.gitconfig.local` に記述してください。


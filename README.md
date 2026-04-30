# dotfiles

Windows (WSL2 / PowerShell), macOS, Linux のマルチプラットフォームに対応した設定ファイル群です。
環境が変わってもエンジニアリングマネージャー（EM）としての高い生産性を維持できるような環境構築を目指し、AIエージェント（Gemini CLI）とObsidianによる情報管理を統合し、マネジメント業務をエンジニアリング視点でハックするための基盤を提供します（EM-Ops）。

## 💡 目指す環境のコンセプト：EM-Ops
本リポジトリを通じて、以下の状態を実現することを目指しています。
- **Logic vs. Data:** マネジメントの「型（プロンプトやスクリプト）」をコード管理し、機密データと完全に分離。
- **AI-Driven Management:** Gemini CLIを活用し、1on1準備やドキュメント作成を自動化。
- **Obsidian Connectivity:** ローカルの知識ベースをAIに接続し、構造化された意思決定を支援。

---

## 🚀 クイックスタート (WSL2 / macOS 共通)

メインとなるモダンな開発環境のセットアップ手順です。MacとWSL2は基本的に共通のスクリプト（`setup.sh`）で環境を構築します。
パッケージ管理は Homebrew に集約し、シェルは `zsh`、プロンプトは `Starship` を使用します。

### 1. 前提条件と準備

**🍎 macOS の場合**
- Git がインストールされていること
- Homebrew がインストールされていること

**🪟 Windows (WSL2) の場合**
1. **WSL2 のインストール**: 管理者権限の PowerShell で以下を実行し、PCを再起動します。
   ```powershell
   wsl --install
   ```
2. **WSL2 内でのパッケージ準備**: Ubuntuのターミナルを開き、Git と zsh をインストールします。
   ```bash
   sudo apt update && sudo apt install -y git zsh
   ```
3. **Windows Terminal のフォント設定**: [Starship](https://starship.rs/) のアイコンを正しく表示するため、Windows 側に [Nerd Fonts](https://www.nerdfonts.com/)（JetBrainsMono Nerd Fontなど）をインストールし、Windows Terminal の Ubuntu プロファイルのフォントに設定してください。

### 2. リポジトリのクローンとセットアップ

ターミナル（Mac または WSL2のUbuntu）を開き、以下のコマンドを実行します。
※WSL2の場合は、パフォーマンス確保のため必ずWindows側（`/mnt/c/`）ではなく、**WSL2のホームディレクトリ（`~/`）直下**にクローンしてください。

```bash
# 1. ホームディレクトリへ移動してクローン
cd $HOME
git clone [https://github.com/radiocat/dotfiles.git](https://github.com/radiocat/dotfiles.git)

# 2. セットアップスクリプトの実行
cd dotfiles
chmod +x setup.sh
./setup.sh
```

`setup.sh` を実行すると、`Brewfile` に定義された必須ツール（zsh, fzf, ripgrep, gh, python, node, neovim 等）が一括インストールされ、Pythonの仮想環境（`.venv`）や公式のGemini CLIが自動でセットアップされます。

### 3. デフォルトシェルの変更と再起動
セットアップ完了後、デフォルトのシェルを `zsh` に変更し、ターミナルを再起動してください。
```bash
chsh -s $(which zsh)
```

### 4. 環境変数と Obsidian の設定
個人固有の設定やAPIキーは、Git管理から除外される `.env.local` に記述します。（`setup.sh` で `.env.local.example` から自動コピーされています）

1. `dotfiles/.env.local` を開き、取得した Google Gemini の API キーを設定します。
2. `OBSIDIAN_VAULT_PATH` に Obsidian の Vault パスを設定します。
   - ※ WSL2からWindows側のVaultを参照する場合は `/mnt/c/Users/yourname/Documents/ObsidianVault` のような形式で記述します。

---

## 🪟 Windows 環境のセットアップ（PowerShell）

PowerShell環境を個別に利用する場合のセットアップ手順です。Wingetを使用してツール群をインストールします。

### 1. インストール手順

**管理者権限** で PowerShell を実行し、以下のコマンドを実行してください。

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

### 2. インストールされるものと設定

`install.ps1` により、PowerShell 7, Windows Terminal, Starship, Neovim, Python 3, Node.js などのツールや、Gemini CLI (`google-genai`, `@google/gemini-cli`) がインストールされ、シンボリックリンクが作成されます。

**APIキーの設定:**
Windowsの環境変数設定画面、または以下のコマンドで `GOOGLE_API_KEY` を設定し、ターミナルを再起動してください。
```powershell
[System.Environment]::SetEnvironmentVariable('GOOGLE_API_KEY', 'ここに取得したAPIキーを入力', 'User')
```

---

## 🤖 AI機能の使い方

### 1. AIエージェント (`genai.py`)

仮想環境 (`.venv`) 内のPythonを利用し、標準入力や引数からAI（Gemini 1.5 Pro等）を呼び出します。Vault内の `AGENTS.md` を参照し、マネジメント哲学に基づいた回答を生成します。

```bash
# 1on1の生メモからネクストアクションを抽出
cat meeting_notes.md | genai "このメモからToDoを抽出して"

# スキル（プロンプトテンプレート）の活用
# scripts/skills/1on1.md などの型を使って定型業務を実行
cat 1on1_notes.md | genai --skill 1on1
```

### 2. Obsidian 連携

`fzf` と `ripgrep` を組み合わせ、ターミナルからノートを高速検索・編集するワークフローを提供します。
また、AIツールからマウントされたパス (`OBSIDIAN_VAULT_PATH`) 経由で直接読み書きを行い、スケジュールの反映やドキュメント化を自動化します。

---

## 📁 ディレクトリ構成

* `scripts/`: EM業務を自動化する AI/Python スクリプト群 (EM-Skills)
* `zsh/`: macOS / WSL2 共通のシェル設定
* `vim/`: エディタ共通設定
* `windows/`: Windows 用設定ファイル (PowerShell プロファイル等)
* `Brewfile`: ツール一括管理シート (Homebrew用)
* `install.ps1`: Windows (PowerShell) 用インストーラー
* `setup.sh`: macOS / WSL2 共通インストーラー
* `.env.local.example`: 環境変数のテンプレート（Git管理外の `.env.local` を作成して使用）

---

## 🛠️ カスタマイズ & Tips

- **機密情報の管理**: 個人固有の設定やAPIキー、Gitのクレデンシャルは、Git管理から除外される `.env.local` および `.gitconfig.local` に記述してください。
- **Gitエイリアスの活用**: `.gitconfig` に `st` (status) や `cm` (commit) などのエイリアスが設定されています。モダンなプロンプト(Starship)と併せて、直感的なGit操作が可能です。
- **ファイルシステムの違い (WSL2)**: dotfilesはWSL2の `~/` 直下で管理し、業務ドキュメント(Obsidian)はWindows側のフォルダで管理します。AIはこの2つの環境を `/mnt/c/` 経由で繋ぐことで連携します。

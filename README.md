# dotfiles

Windows (WSL2 / PowerShell), macOS, Linux のマルチプラットフォームに対応した設定ファイル群です。
AIエージェント（Gemini CLI）やObsidianによる情報管理を統合し、OS環境が変わっても一貫した高い生産性を維持できるような仕組みを構築しています。（コンセプト：EM-Ops）

---

MacとWSL2は基本的に共通のスクリプト（`setup.sh`）で環境を構築します。パッケージ管理は Homebrew に集約し、シェルは `zsh`、プロンプトは `Starship` を使用します。

## 🪟 Windows 環境のセットアップ

Windows環境では、最初にベースとなるPowerShell環境を整えた後、追加でWSL2環境を構築することでMacと同等のモダンな運用環境を実現します。

### Step 1: PowerShell環境の構築

まずはWindowsネイティブ（PowerShell）の環境をセットアップします。

1. **管理者権限** で PowerShell を実行し、Gitをインストールします（未インストールの場合）。
   ```powershell
   winget install --id Git.Git -e --source winget
   ```

2. リポジトリをクローンしてセットアップスクリプトを実行します。
   ```powershell
   cd $HOME
   git clone https://github.com/radiocat/dotfiles.git
   Set-ExecutionPolicy RemoteSigned -Scope Process -Force; ./dotfiles/install.ps1
   ```

   `install.ps1` により、PowerShell 7, Windows Terminal, Neovim, Python 3 などの必須ツールがインストールされ、初期設定が行われます。

### Step 2: WSL2環境の構築（推奨）

Macと同じ `zsh` ベースのモダンな環境を利用するため、WSL2を導入します。

1. **WSL2のインストール**: 管理者権限の PowerShell で以下を実行し、PCを再起動します。
   ```powershell
   wsl --install
   ```

2. **WSL2内のパッケージ準備**: Ubuntuのターミナルを開き、Git と zsh をインストールします。
   ```bash
   sudo apt update && sudo apt install -y git zsh
   ```

3. **Windows Terminal のフォント設定**: [Starship](https://starship.rs/) のアイコンを正しく表示するため、Windows 側に [Nerd Fonts](https://www.nerdfonts.com/)（JetBrainsMono Nerd Fontなど）をインストールし、Windows Terminal の Ubuntu プロファイルのフォントに設定してください。


4. **セットアップの実行**: Ubuntuのターミナルで以下を実行します。  
   ※必ずWindows側（`/mnt/c/`）ではなく、**WSL2のホームディレクトリ（`~/`）直下**で行ってください。
   ```bash
   cd $HOME
   git clone https://github.com/radiocat/dotfiles.git
   cd dotfiles
   chmod +x setup.sh
   ./setup.sh
   ```

   ※WSL2環境での `setup.sh` 実行時は、Macと共通のCLIツールやAI環境が構築されます。

## 🍎 macOS 環境のセットアップ

Macの場合は、最初から `setup.sh` を実行することで、CLIツールに加えてMac専用のGUIアプリも一括でインストールできます。  
（Homebrewのインストールもスクリプト内で自動的に行われます）

### 1. セットアップの実行

ターミナルを開き、以下のコマンドを実行します。  
（※Mac標準のGitを使用します。初回実行時に「Command Line Tools」のインストールを求められた場合は、画面の指示に従ってください）

```bash
cd $HOME
git clone https://github.com/radiocat/dotfiles.git
cd dotfiles
chmod +x setup.sh
./setup.sh
```

`setup.sh` により以下の処理が自動で実行されます。

* `Brewfile` に基づく共通CLIツール（zsh, Starship, fzf, Neovim 等）のインストール
* **`Brewfile.macos` に基づくMac専用GUIアプリ（iTerm2, Google 日本語入力, Karabiner-Elements 等）のインストール**
* Python仮想環境（`.venv`）の作成とAIツール（`genai.py` 用ライブラリ）のセットアップ
* 公式 Gemini CLI のインストール
* 各種設定ファイルのシンボリックリンク作成

セットアップ完了後、デフォルトシェルを `zsh` に変更してターミナルを再起動してください。
```bash
chsh -s $(which zsh)
```

---

## ⚙️ 環境変数と APIキーの設定

利用する環境に合わせて、以下の方法で Google Gemini の API キーや Obsidian の Vault パスを設定します。

### Windows (PowerShell) 環境の場合

PowerShell環境でGemini CLIなどを利用する場合は、Windowsの環境変数に直接設定します。PowerShellで以下のコマンドを実行し、ターミナルを再起動してください。

```powershell
[System.Environment]::SetEnvironmentVariable('GOOGLE_API_KEY', 'ここに取得したAPIキーを入力', 'User')
```

### Mac / WSL2 環境の場合 (`.env.local`)

MacおよびWSL2では、Git管理から除外される `.env.local` に記述します（`setup.sh` 実行時に `.env.local.example` から自動作成されます）。

1. `dotfiles/.env.local` を開き、取得した Google Gemini の API キー（`GOOGLE_API_KEY`）を設定します。
2. `OBSIDIAN_VAULT_PATH` に Obsidian の Vault パスを設定します。
   * ※ WSL2からWindows側のVaultを参照する場合は `/mnt/c/Users/ユーザー名/Documents/Vault` のような形式で記述します。

### Git 環境設定

- **`.gitconfig.local`**: コミット用のユーザー名・メールアドレスを記述します。共通の `.gitconfig` から読み込まれる設計で、個人情報の流出を防ぎます。

### シンボリックリンクによる設定ファイルの統合管理
`install.ps1` および `setup.sh` は、ファイルを直接コピーするのではなく、このリポジトリ内の各設定ファイルへの**シンボリックリンク**をOSの所定の場所に作成します。
- **運用の狙い**: 手元の環境で設定を変更した際、即座にこのリポジトリ内に差分として反映されます。これにより、設定のバージョン管理が容易になり、複数端末間での環境同期をスムーズに行うことができます。
- 例） **`cdv` エイリアス**: コマンド一つで即座に Obsidian の Vault（`$OBSIDIAN_VAULT_PATH`）へ移動します。思考をすぐにメモへ変換するための最速ルートです。

### Python仮想環境（`.venv`）による依存関係の分離
AIスクリプト（`genai.py` など）を動作させるための環境です。
- **運用の狙い**: OS全体のPython環境を汚染しないよう、リポジトリ内に専用の仮想環境（`.venv`）を構築します。AIツール群はこの隔離環境で安全に動作します。

---

## 🛠️ 主要ツールの設定意図とワークフロー

### AIエージェント (`genai.py`)

仮想環境 (`.venv`) 内のPythonを利用し、標準入力や引数からAI（Gemini 1.5 Pro等）を呼び出します。Vault内の `AGENTS.md` を参照し、標準入力からのテキスト処理や、Obsidianのノート要約などに活用できます。

```bash
# 1on1の生メモからネクストアクションを抽出
cat meeting_notes.md | genai "このメモからToDoを抽出して"

# スキル（プロンプトテンプレート）の活用
# scripts/skills/1on1.md などの型を使って定型業務を実行
cat 1on1_notes.md | genai --skill 1on1
```

### Obsidian 連携

`fzf` と `ripgrep` を組み合わせ、ターミナルからノートを高速検索・編集するワークフローを提供します。
また、AIツールからマウントされたパス (`OBSIDIAN_VAULT_PATH`) 経由で直接読み書きを行い、スケジュールの反映やドキュメント化を自動化します。

### Neovim エディタ環境

ターミナルでの「ちょっとした編集」や「Gitコミットメッセージ」を爆速で処理するための設定です。IDEのような重厚さではなく、軽量さと操作の快適さを追求しています。

- **モダンなNeovim (`init.lua`)**: Luaベースの最新構成（Lazy.nvim採用）で、爆速な起動と強力な編集機能を提供します。
- **レガシーVimのアーカイブ (`vimrc`, `gvimrc`)**: 過去の設定をアーカイブとして残していますが、**内容は古いままでメンテナンスされていません。** Neovimが使えない環境などで活用する場合は、ご自身で内容を現代の環境に合わせて修正してください。

---

## 🛠️ カスタマイズ & Tips

- **機密情報の管理**: 個人固有の設定やAPIキー、Gitのクレデンシャルは、Git管理から除外される `.env.local` および `.gitconfig.local` に記述してください。
- **Gitエイリアスの活用**: `.gitconfig` に `st` (status) や `cm` (commit) などのエイリアスが設定されています。モダンなプロンプト(Starship)と併せて、直感的なGit操作が可能です。
- **ファイルシステムの違い (WSL2)**: dotfilesはWSL2の `~/` 直下で管理し、業務ドキュメント(Obsidian)はWindows側のフォルダで管理します。AIはこの2つの環境を `/mnt/c/` 経由で繋ぐことで連携します。

---

## 📁 ディレクトリ構成

* `scripts/`: AIエージェント（`genai.py`）などのユーティリティスクリプト
* `zsh/`: macOS / WSL2 共通のシェル設定
* `git/`: Gitの設定ファイル群（`.gitconfig` など。セットアップ時にローカル用の `.gitconfig.local` も作成されます）
* `starship/`: ターミナルプロンプト（Starship）の設定
* `nvim/`, `vim/`: Neovim およびレガシーVim の設定
* `windows/`: Windows（PowerShell）用の設定ファイル
* `.venv/`: セットアップスクリプトによって作成されるPython仮想環境（AIエージェントのライブラリがインストールされます）
* `Brewfile`, `Brewfile.macos`: Homebrewによるツール管理ファイル
* `install.ps1`: Windows用セットアップスクリプト
* `setup.sh`: macOS / WSL2 共通インストーラー
* `.env.local.example`: 環境変数設定ファイルのテンプレート（セットアップ時に `.env.local` が作成されます）
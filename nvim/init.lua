-- =============================================================================
-- EM-Ops Neovim Config (Minimal & Fast)
-- =============================================================================

-- 1. Plugin Manager (lazy.nvim) の自動インストール
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 2. プラグイン設定
require("lazy").setup({
  -- 外観
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  
  -- 検索 (Unite.vim の後継)
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  
  -- Git (GitGutter の後継)
  { "lewis6991/gitsigns.nvim" },
  { "tpope/vim-fugitive" }, -- コミットメッセージ作成に必須
  
  -- Markdown (Obsidian ユーザー向け)
  { "preservim/vim-markdown", ft = "markdown" },
})

-- 3. 基本設定 (既存の vimrc から継承)
vim.opt.number = true         -- 行番号表示
vim.opt.tabstop = 2           -- タブ幅
vim.opt.shiftwidth = 2        -- インデント幅
vim.opt.expandtab = true      -- スペース使用
vim.opt.hlsearch = true       -- 検索ハイライト
vim.opt.ignorecase = true     -- 大文字小文字無視
vim.opt.smartcase = true      -- 大文字が混じれば区別
vim.opt.clipboard = "unnamedplus" -- クリップボード連携

-- 4. キーバインド (過去の設定を完全踏襲)
local keymap = vim.keymap.set

-- jj でエスケープ
keymap("i", "jj", "<ESC>", { silent = true })
keymap("i", "っj", "<ESC>", { silent = true })

-- インサートモードでのカーソル移動
keymap("i", "<C-j>", "<Down>")
keymap("i", "<C-k>", "<Up>")
keymap("i", "<C-h>", "<Left>")
keymap("i", "<C-l>", "<Right>")

-- 日本語入力オンのままでも使えるコマンド
keymap("n", "あ", "a")
keymap("n", "い", "i")
keymap("n", "う", "u")
keymap("n", "お", "o")
keymap("n", "っd", "dd")
keymap("n", "っy", "yy")

-- Telescope (Space + f を Unite の代わりに設定)
local builtin = require('telescope.builtin')
keymap('n', '<Space>ff', builtin.find_files, {})
keymap('n', '<Space>fg', builtin.live_grep, {})
keymap('n', '<Space>fb', builtin.buffers, {})

-- 5. カラースキーム適用
vim.cmd.colorscheme("catppuccin")
require('lualine').setup()
require('gitsigns').setup()
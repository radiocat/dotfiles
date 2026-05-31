# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains configuration files (dotfiles) designed to provide a consistent, high-productivity development environment across macOS, WSL2 (Linux), and Windows (PowerShell). The core concept, "EM-Ops," focuses on integrating modern CLI tools, AI agents (Gemini), and information management (Obsidian) into a unified workflow.

## Commands

### Setup and Installation

- **macOS / WSL2**:
  - Run `./setup.sh` to install Homebrew, common CLI tools (via `Brewfile`), macOS GUI apps (via `Brewfile.macos`), set up symlinks, and initialize the Python virtual environment.
- **Windows (PowerShell)**:
  - Run `./install.ps1` to set up the PowerShell environment and necessary tools.

### Development and Usage

- **AI Agent**: The `scripts/genai.py` script provides an AI interface. It runs within the `.venv` created during setup.
- **Environment Configuration**:
  - Edit `.env.local` to set `GOOGLE_API_KEY` and `OBSIDIAN_VAULT_PATH`.
  - Edit `.gitconfig.local` for personal Git credentials.

## Architecture and Structure

The repository is organized by tool and environment:

- `zsh/`: Shell configuration for macOS and WSL2.
 `- `nvim/`: Neovim configuration.
- `vim/`: Legacy Vim configuration.
- `git/`: Git configuration files (e.g., `.gitconfig`).
- `starship/`: Starship prompt configuration.
- `windows/`: PowerShell-specific configurations.
- `scripts/`: Utility scripts, including the `genai.py` AI agent.
- `Brewfile` & `Brewfile.macos`: Homebrew package manifests for common tools and macOS-specific GUI apps.
- `.venv/`: Python virtual environment containing the `google-genai` library and other dependencies for the AI agent.

## Key Components

- **AI Integration**: Powered by Google's Gemini via `google-genai` Python library and the `@google/gemini-cli` npm package.
- **Text Editing**: Neovim and Vim are the primary editors.
- **Shell**: Zsh is the standard shell for macOS/WSL2.
- **Prompt**: Starship provides a cross-shell, highly customizable prompt.

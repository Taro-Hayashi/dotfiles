#!/bin/bash
set -e

# ── Homebrew ──────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# ── GitHub CLI ────────────────────────────────────────────
if ! brew info --formula gh 2>/dev/null | grep -q "Installed"; then
  brew install gh
fi
if ! gh auth status &>/dev/null; then
  gh auth login
fi

# ── Clone dotfiles (server branch) ────────────────────────
GITHUB_DIR="$(pwd)/GitHub"
mkdir -p "$GITHUB_DIR"
if [ ! -d "$GITHUB_DIR/dotfiles" ]; then
  git clone -b server https://github.com/Taro-Hayashi/dotfiles.git "$GITHUB_DIR/dotfiles"
else
  git -C "$GITHUB_DIR/dotfiles" checkout server
  git -C "$GITHUB_DIR/dotfiles" pull origin server
fi

# ── Setup ─────────────────────────────────────────────────
"$GITHUB_DIR/dotfiles/setup.sh"

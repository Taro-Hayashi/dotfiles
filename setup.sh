#!/bin/bash
set -e

DOTFILES_REPO="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_HOME="$HOME/dotfiles"

seed_store() {
  local repo_rel="$1"
  local home_rel="${2:-$1}"
  local src="$DOTFILES_REPO/$repo_rel"
  local dst="$DOTFILES_HOME/$home_rel"

  if [ ! -e "$src" ] && [ ! -L "$src" ]; then
    echo "Missing seed in repo: $src (skipped)"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [ -d "$src" ] && [ ! -L "$src" ]; then
    mkdir -p "$dst"
    rsync -a --ignore-existing "$src"/ "$dst"/
    echo "Seeded directory: $dst"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "Already exists in ~/dotfiles: $dst (kept)"
    return
  fi

  cp -R "$src" "$dst"
  echo "Seeded file: $dst"
}

link_from_store() {
  local home_rel="$1"
  local src="$DOTFILES_HOME/$home_rel"
  local dst="$HOME/$home_rel"

  if [ ! -e "$src" ] && [ ! -L "$src" ]; then
    echo "Missing file in ~/dotfiles: $src (skipped)"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  ln -s "$src" "$dst"
  echo "Linked: $dst -> $src"
}

install_formula() {
  if brew info --formula "$1" 2>/dev/null | grep -q "Installed"; then
    echo "Already installed: $1 (skipped)"
  else
    brew install "$1"
  fi
}

install_cask() {
  local artifacts
  artifacts=$(brew info --cask --json=v2 "$1" 2>/dev/null \
    | python3 -c "
import sys, json
data = json.load(sys.stdin)
for cask in data.get('casks', []):
    for artifact in cask.get('artifacts', []):
        if isinstance(artifact, dict):
            for key in ('app', 'suite'):
                if key in artifact:
                    for item in artifact[key]:
                        if isinstance(item, str):
                            print(item)
" 2>/dev/null)

  if brew list --cask "$1" &>/dev/null; then
    if [ -z "$artifacts" ]; then
      echo "Already installed: $1 (skipped)"
      return
    fi

    local app_exists=false
    while IFS= read -r artifact; do
      [ -z "$artifact" ] && continue
      for dir in "/Applications" "$HOME/Applications"; do
        [ -e "$dir/$artifact" ] && app_exists=true && break 2
      done
    done <<< "$artifacts"
    if $app_exists; then
      echo "Already installed: $1 (skipped)"
      return
    fi
    echo "App missing, reinstalling: $1"
    brew reinstall --cask "$1"
    return
  fi

  while IFS= read -r artifact; do
    [ -z "$artifact" ] && continue
    for dir in "/Applications" "$HOME/Applications"; do
      if [ -e "$dir/$artifact" ]; then
        echo "Removing existing $dir/$artifact before install..."
        sudo rm -rf "$dir/$artifact"
      fi
    done
  done <<< "$artifacts"

  brew install --cask "$1"
}

# ── CLI Tools ─────────────────────────────────────────────
install_formula gh
install_formula git
install_formula node
install_formula ollama
install_formula wget
install_formula aider

# ── Apps & Fonts ──────────────────────────────────────────
install_cask ghostty
install_cask zed
install_cask font-zed-mono
install_cask font-zen-maru-gothic
install_cask kicad
install_cask bambu-studio
install_cask betterdisplay
install_cask codex
install_cask zen-browser
install_cask brave-browser
install_cask google-chrome
install_cask github
install_cask hammerspoon
install_cask steam
install_cask the-unarchiver
install_cask tailscale-app
install_cask vlc
install_cask xnviewmp
install_cask syncthing
install_cask jellyfin-media-player

# ── Claude Code CLI ───────────────────────────────────────
if npm list -g --depth=0 2>/dev/null | grep -q "@anthropic-ai/claude-code"; then
  echo "Already installed: @anthropic-ai/claude-code (skipped)"
else
  npm install -g @anthropic-ai/claude-code
fi

# ── Seed ~/dotfiles and link into $HOME ───────────────────
mkdir -p "$DOTFILES_HOME" "$DOTFILES_HOME/.config" "$DOTFILES_HOME/.ssh" "$HOME/.config" "$HOME/.ssh"

seed_store home/.zshrc .zshrc
seed_store home/.zprofile .zprofile
seed_store home/.gitconfig .gitconfig
seed_store home/.profile .profile
seed_store home/.zshenv .zshenv
seed_store home/.tcshrc .tcshrc
seed_store home/.aider.conf.yml .aider.conf.yml
seed_store home/.ssh/config .ssh/config
seed_store home/.hammerspoon .hammerspoon
seed_store home/.plasticity .plasticity
seed_store config/fish .config/fish
seed_store config/gh .config/gh
seed_store config/git .config/git
seed_store config/ghostty .config/ghostty
seed_store config/zed .config/zed

chmod 700 "$DOTFILES_HOME/.ssh"
[ -f "$DOTFILES_HOME/.ssh/config" ] && chmod 600 "$DOTFILES_HOME/.ssh/config"

link_from_store .zshrc
link_from_store .zprofile
link_from_store .gitconfig
link_from_store .profile
link_from_store .zshenv
link_from_store .tcshrc
link_from_store .aider.conf.yml
link_from_store .ssh/config
link_from_store .hammerspoon
link_from_store .plasticity
link_from_store .config/fish
link_from_store .config/gh
link_from_store .config/git
link_from_store .config/ghostty
link_from_store .config/zed

echo "Done! Open a new terminal to apply shell settings."

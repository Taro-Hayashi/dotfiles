#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# ── CLI Tools ─────────────────────────────────────────────
install_formula() {
  if brew info --formula "$1" 2>/dev/null | grep -q "Installed"; then
    echo "Already installed: $1 (skipped)"
  else
    brew install "$1"
  fi
}

install_formula gh
install_formula git
install_formula node
install_formula wget

# ── Apps & Fonts ──────────────────────────────────────────
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

  # If Homebrew manages this cask, check the app actually exists on disk
  if brew list --cask "$1" &>/dev/null; then
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

  # Remove any existing app/suite not managed by Homebrew (web/MAS-installed)
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

install_cask ghostty
install_cask zed
install_cask font-zed-mono
install_cask font-zen-maru-gothic
install_cask betterdisplay
install_cask zen-browser
install_cask brave-browser
install_cask claude
install_cask github
install_cask the-unarchiver
install_cask syncthing

# ── Claude Code CLI ───────────────────────────────────────
if npm list -g --depth=0 2>/dev/null | grep -q "@anthropic-ai/claude-code"; then
  echo "Already installed: @anthropic-ai/claude-code (skipped)"
else
  npm install -g @anthropic-ai/claude-code
fi

# ── Symlinks: ~/.config ───────────────────────────────────
mkdir -p ~/.config

link_config() {
  local src="$DOTFILES/config/$1"
  local dst="$HOME/.config/$1"
  rm -rf "$dst"
  ln -s "$src" "$dst"
  echo "Linked: $dst -> $src"
}

link_config ghostty
link_config zed

# ── Symlinks: home ────────────────────────────────────────
link_home() {
  local src="$DOTFILES/home/$1"
  local dst="$HOME/$1"
  rm -f "$dst"
  ln -s "$src" "$dst"
  echo "Linked: $dst -> $src"
}

link_home .zshrc
link_home .zprofile
link_home .gitconfig

# ── macOS System Settings ─────────────────────────────────
echo "Applying macOS system settings..."

# Dock
defaults write com.apple.dock tilesize -int 56
defaults write com.apple.dock orientation -string bottom
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true

# Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string clmv
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Trackpad
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

killall Dock
killall Finder

# ── Docker ───────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  if [[ "$(uname)" == "Darwin" ]]; then
    brew install --cask docker
    echo "Docker Desktop installed. Please launch Docker Desktop before continuing."
  else
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
    echo "Docker installed. Re-login required to use without sudo."
  fi
else
  echo "Already installed: docker (skipped)"
fi

# ── Server Services ───────────────────────────────────────
start_service() {
  local name="$1"
  local dir="$DOTFILES/services/$name"
  echo "Starting $name..."
  if [[ "$(uname)" == "Darwin" ]]; then
    docker compose -f "$dir/compose.yml" -p "$name" up -d
  else
    sudo docker compose -f "$dir/compose.yml" -p "$name" up -d
  fi
}

start_service paperless-ngx
start_service jellyfin
start_service stirling-pdf
start_service homarr
start_service immich
start_service open-webui

echo ""
echo "サービスのポート一覧:"
echo "  paperless-ngx  http://localhost:8000"
echo "  jellyfin       http://localhost:8096"
echo "  stirling-pdf   http://localhost:8085"
echo "  homarr         http://localhost:7575"
echo "  immich         http://localhost:2283"
echo "  open-webui     http://localhost:3000"
echo ""
echo "Done! Open a new terminal to apply shell settings."

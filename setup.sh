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

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "Already exists in ~/dotfiles: $dst (kept)"
    return
  fi

  cp -R "$src" "$dst"
  echo "Seeded: $dst"
}

link_from_store() {
  local home_rel="$1"
  local src="$DOTFILES_HOME/$home_rel"
  local dst="$HOME/$home_rel"

  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  ln -s "$src" "$dst"
  echo "Linked: $dst -> $src"
}

reload_launch_agent() {
  local label="$1"
  local plist="$HOME/Library/LaunchAgents/$label.plist"

  mkdir -p "$HOME/Library/LaunchAgents"
  launchctl bootout "gui/$(id -u)" "$plist" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$plist"
  launchctl kickstart -k "gui/$(id -u)/$label"
}

setup_open_webui() {
  local root="$DOTFILES_HOME/.local/open-webui"
  local py_prefix
  local py_bin
  local script_path="$DOTFILES_HOME/bin/open-webui-start"
  local plist="$HOME/Library/LaunchAgents/local.open-webui.plist"

  py_prefix="$(brew --prefix python@3.11)"
  py_bin="$py_prefix/bin/python3.11"

  mkdir -p "$root/data" "$DOTFILES_HOME/bin" "$DOTFILES_HOME/logs"

  if [ ! -x "$root/venv/bin/python" ]; then
    "$py_bin" -m venv "$root/venv"
  fi

  "$root/venv/bin/pip" install -U pip open-webui

  if [ ! -f "$root/.secret_key" ]; then
    openssl rand -hex 32 > "$root/.secret_key"
  fi

  cat > "$script_path" <<EOF
#!/bin/bash
set -e
export DATA_DIR="\$HOME/dotfiles/.local/open-webui/data"
export WEBUI_SECRET_KEY="\$(cat "\$HOME/dotfiles/.local/open-webui/.secret_key")"
exec "\$HOME/dotfiles/.local/open-webui/venv/bin/open-webui" serve
EOF
  chmod +x "$script_path"

  cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>local.open-webui</string>
  <key>ProgramArguments</key>
  <array>
    <string>$script_path</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$DOTFILES_HOME/logs/open-webui.log</string>
  <key>StandardErrorPath</key>
  <string>$DOTFILES_HOME/logs/open-webui.err.log</string>
</dict>
</plist>
EOF

  reload_launch_agent local.open-webui
}

setup_uptime_kuma() {
  local root="$DOTFILES_HOME/apps/uptime-kuma"
  local script_path="$DOTFILES_HOME/bin/uptime-kuma-start"
  local plist="$HOME/Library/LaunchAgents/local.uptime-kuma.plist"

  mkdir -p "$DOTFILES_HOME/apps" "$DOTFILES_HOME/bin" "$DOTFILES_HOME/logs"

  if [ ! -d "$root/.git" ]; then
    git clone https://github.com/louislam/uptime-kuma.git "$root"
  else
    git -C "$root" pull --ff-only
  fi

  (
    cd "$root"
    npm run setup
  )

  cat > "$script_path" <<EOF
#!/bin/bash
set -e
cd "\$HOME/dotfiles/apps/uptime-kuma"
exec node server/server.js
EOF
  chmod +x "$script_path"

  cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>local.uptime-kuma</string>
  <key>ProgramArguments</key>
  <array>
    <string>$script_path</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$root</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$DOTFILES_HOME/logs/uptime-kuma.log</string>
  <key>StandardErrorPath</key>
  <string>$DOTFILES_HOME/logs/uptime-kuma.err.log</string>
</dict>
</plist>
EOF

  reload_launch_agent local.uptime-kuma
}

start_gui_app() {
  local app_name="$1"

  if [ -d "/Applications/$app_name.app" ]; then
    open -ga "$app_name" || true
  fi
}

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
install_formula python@3.11
install_formula wget
install_formula aider

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
install_cask codex
install_cask font-zed-mono
install_cask font-zen-maru-gothic
install_cask betterdisplay
install_cask brave-browser
install_cask github
install_cask jellyfin
install_cask bambu-studio
install_cask hammerspoon
install_cask tailscale-app
install_cask the-unarchiver
install_cask syncthing

# ── Claude Code CLI ───────────────────────────────────────
if npm list -g --depth=0 2>/dev/null | grep -q "@anthropic-ai/claude-code"; then
  echo "Already installed: @anthropic-ai/claude-code (skipped)"
else
  npm install -g @anthropic-ai/claude-code
fi

# ── Seed ~/dotfiles and link into $HOME ───────────────────
mkdir -p "$DOTFILES_HOME"

seed_store home/.zshrc .zshrc
seed_store home/.zprofile .zprofile
seed_store home/.gitconfig .gitconfig
seed_store home/.ssh/config .ssh/config
seed_store config/ghostty .config/ghostty
seed_store config/zed .config/zed

mkdir -p "$DOTFILES_HOME/.ssh" "$HOME/.config"
chmod 700 "$DOTFILES_HOME/.ssh"
[ -f "$DOTFILES_HOME/.ssh/config" ] && chmod 600 "$DOTFILES_HOME/.ssh/config"

link_from_store .zshrc
link_from_store .zprofile
link_from_store .gitconfig
link_from_store .ssh/config
link_from_store .config/ghostty
link_from_store .config/zed

if [ -e "$DOTFILES_HOME/.hammerspoon" ] || [ -L "$DOTFILES_HOME/.hammerspoon" ]; then
  link_from_store .hammerspoon
fi

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

# ── Native Services ───────────────────────────────────────
setup_open_webui
setup_uptime_kuma
start_gui_app Jellyfin

# ── Server Services ───────────────────────────────────────
start_service() {
  local name="$1"
  local dir="$DOTFILES_REPO/services/$name"
  echo "Starting $name..."
  if [[ "$(uname)" == "Darwin" ]]; then
    docker compose -f "$dir/compose.yml" -p "$name" up -d
  else
    sudo docker compose -f "$dir/compose.yml" -p "$name" up -d
  fi
}

start_service paperless-ngx
start_service immich

echo ""
echo "サービスのポート一覧:"
echo "  jellyfin       http://localhost:8096"
echo "  open-webui     http://localhost:8080"
echo "  paperless-ngx  http://localhost:8000"
echo "  uptime-kuma    http://localhost:3001"
echo "  immich         http://localhost:2283"
echo ""
echo "Done! Open a new terminal to apply shell settings."

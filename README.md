# dotfiles

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Taro-Hayashi/dotfiles/main/bootstrap.sh)"
```

`bootstrap.sh` は Homebrew と GitHub CLI を用意して repo を clone し、`setup.sh` を実行します。

`setup.sh` は repo の設定を直接 `$HOME` に置かず、まず `~/dotfiles` に不足分だけコピーしてから、ホーム側にシンボリックリンクを張ります。既存の `~/dotfiles` は上書きしません。

## インストールされるもの

CLI:
- `gh`
- `git`
- `node`
- `ollama`
- `wget`
- `aider`
- `@anthropic-ai/claude-code`

Apps / casks:
- `ghostty`
- `zed`
- `font-zed-mono`
- `font-zen-maru-gothic`
- `kicad`
- `bambu-studio`
- `betterdisplay`
- `codex`
- `zen-browser`
- `brave-browser`
- `google-chrome`
- `github`
- `hammerspoon`
- `steam`
- `the-unarchiver`
- `tailscale-app`
- `vlc`
- `xnviewmp`
- `syncthing`
- `jellyfin-media-player`

## `~/dotfiles` に配置される設定

ホーム直下:
- `.zshrc`
- `.zprofile`
- `.gitconfig`
- `.profile`
- `.zshenv`
- `.tcshrc`
- `.aider.conf.yml`
- `.ssh/config`
- `.hammerspoon/`
- `.plasticity/`

`~/.config` 配下:
- `fish/`
- `gh/`
- `git/`
- `ghostty/`
- `zed/`

## リンクされる場所

- `~/.zshrc`
- `~/.zprofile`
- `~/.gitconfig`
- `~/.profile`
- `~/.zshenv`
- `~/.tcshrc`
- `~/.aider.conf.yml`
- `~/.ssh/config`
- `~/.hammerspoon`
- `~/.plasticity`
- `~/.config/fish`
- `~/.config/gh`
- `~/.config/git`
- `~/.config/ghostty`
- `~/.config/zed`

## 構成

```text
dotfiles/
├── home/        # ~/dotfiles 配下のホーム直下設定
├── config/      # ~/dotfiles/.config 配下の設定
├── bootstrap.sh
└── setup.sh
```

## repo に含めないもの

- `config/gh/hosts.yml`
- `home/.claude.json`
- `home/.claude.json.backup`
- `home/.plasticity/license.key`
- `home/.plasticity/license.lic`
- `**/.DS_Store`

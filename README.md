# dotfiles (server)

Debian/Ubuntu サーバー向けセットアップ。

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Taro-Hayashi/dotfiles/server/bootstrap-server.sh)"
```

## インストールされるもの

**CLI ツール**

| パッケージ | 用途 |
|---|---|
| aider | AI ペアプログラミング |
| gh | GitHub CLI |
| git | バージョン管理 |
| node | Node.js |
| python@3.11 | Open WebUI 用 Python |
| wget | ファイル取得 |
| @anthropic-ai/claude-code | Claude Code CLI |
| codex | Codex CLI |

**アプリ / フォント**

| パッケージ | 用途 |
|---|---|
| ghostty | ターミナル |
| zed | エディタ |
| font-zed-mono | Ghostty / Zed 用フォント |
| font-zen-maru-gothic | 日本語フォント |
| betterdisplay | ディスプレイ調整 |
| brave-browser | ブラウザ |
| github | GitHub Desktop |
| jellyfin | ネイティブ版メディアサーバー |
| bambu-studio | Bambu Lab スライサー |
| hammerspoon | macOS 自動化 |
| tailscale-app | Tailscale GUI |
| the-unarchiver | アーカイブ展開 |
| syncthing | ファイル同期 |

**ネイティブサービス**

| サービス | ポート | 方式 |
|---|---|---|
| [Jellyfin](https://jellyfin.org/) | 8096 | macOS アプリ |
| [Open WebUI](https://docs.openwebui.com/) | 8080 | Python venv + launchd |
| [Uptime Kuma](https://github.com/louislam/uptime-kuma/wiki/%F0%9F%94%A7-How-to-Install) | 3001 | Git clone + Node.js + launchd |

**セルフホストサービス (Docker)**

| サービス | ポート | 用途 |
|---|---|---|
| [paperless-ngx](https://docs.paperless-ngx.com/) | 8000 | 書類管理 |
| [Immich](https://immich.app/) | 2283 | 写真・動画バックアップ |

## セットアップ後の設定

**Immich** — `services/immich/.env` の写真保存先パスを変更する:
```
UPLOAD_LOCATION=/var/lib/immich/upload  # 実際のパスに変更
```

**Open WebUI** — `~/dotfiles/.local/open-webui` に venv / data / secret key を作成し、`launchd` で起動する。

**Uptime Kuma** — `~/dotfiles/apps/uptime-kuma` に clone し、`launchd` で起動する。

**Tailscale** — 初回は System Settings の許可が必要な場合がある。

## フォルダ構成

```
dotfiles/
├── home/                   — 初期値として ~/dotfiles にコピーされるホーム直下の設定
│   ├── .zshrc
│   ├── .zprofile
│   ├── .gitconfig
│   └── .ssh/config
├── config/                 — 初期値として ~/dotfiles/.config にコピーされる設定
│   ├── ghostty/
│   └── zed/
├── apps/                   — ネイティブサービスのアプリ本体や clone
│   └── uptime-kuma/
├── bin/                    — ネイティブサービス起動スクリプト
├── logs/                   — ネイティブサービスのログ
├── services/               — Docker Compose ファイル
│   ├── paperless-ngx/
│   └── immich/
├── bootstrap-server.sh     — 初回セットアップ (git・gh 導入 → clone → setup 実行)
└── setup.sh                — パッケージインストール・~/dotfiles 初期化・サービス起動
```

`setup.sh` は repo のファイルを直接 `$HOME` にリンクせず、まず `~/dotfiles` に初期値をコピーし、その後 `~/.zshrc` や `~/.config/ghostty` などを `~/dotfiles` 側へリンクします。すでに `~/dotfiles` に実体がある場合は上書きしません。

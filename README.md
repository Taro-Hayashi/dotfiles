# dotfiles (server)

Debian/Ubuntu サーバー向けセットアップ。

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Taro-Hayashi/dotfiles/server/bootstrap.sh)"
```

## インストールされるもの

**CLI ツール**

| パッケージ | 用途 |
|---|---|
| gh | GitHub CLI |
| git | バージョン管理 |
| node | Node.js |
| wget | ファイル取得 |
| curl | HTTP クライアント |
| tmux | ターミナルマルチプレクサ |
| htop | プロセスモニタ |
| unzip | アーカイブ展開 |
| @anthropic-ai/claude-code | Claude Code CLI |

**セルフホストサービス (Docker)**

| サービス | ポート | 用途 |
|---|---|---|
| [paperless-ngx](https://docs.paperless-ngx.com/) | 8000 | 書類管理 |
| [Pi-hole](https://pi-hole.net/) | 8080 | DNS 広告ブロック |
| [Uptime Kuma](https://github.com/louislam/uptime-kuma) | 3001 | 死活監視 |
| [FreshRSS](https://freshrss.org/) | 8001 | RSS リーダー |
| [Jellyfin](https://jellyfin.org/) | 8096 | メディアサーバー |
| [Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) | 8085 | PDF 編集ツール |
| [Homarr](https://homarr.dev/) | 7575 | サービスダッシュボード |

## セットアップ後の設定

**Jellyfin** — `services/jellyfin/compose.yml` のメディアパスを変更する:
```yaml
- /media:/media:ro  # 実際のパスに変更
```

**Pi-hole** — `services/pihole/compose.yml` の管理パスワードを設定する:
```yaml
WEBPASSWORD: ""  # パスワードを設定
```

## フォルダ構成

```
dotfiles/
├── home/                   — $HOME にシンボリックリンクされるファイル
│   ├── .zshrc
│   ├── .zprofile
│   └── .gitconfig
├── services/               — Docker Compose ファイル
│   ├── paperless-ngx/
│   ├── pihole/
│   ├── uptime-kuma/
│   ├── freshrss/
│   ├── jellyfin/
│   ├── stirling-pdf/
│   └── homarr/
├── bootstrap.sh            — 初回セットアップ (git・gh 導入 → clone → setup 実行)
└── setup.sh                — パッケージインストール・サービス起動
```

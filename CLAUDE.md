# CLAUDE.md

## プロジェクト概要

macOS環境のdotfilesです。新しいMacに`bootstrap.sh`を実行するだけで環境が再現できます。

## フォルダ構成

```
dotfiles/
├── config/
│   ├── ghostty/                      — Ghosttyターミナルの設定
│   │   ├── config.ghostty
│   │   └── themes/dark-transparent
│   └── zed/                          — Zedエディタの設定
│       ├── keymap.json
│       ├── settings.json
│       ├── prompts/
│       └── themes/
│           ├── light-transparent.json
│           └── dark-transparent.json
├── home/                             — $HOMEにシンボリックリンクされるファイル
│   ├── .zshrc
│   ├── .zprofile
│   └── .gitconfig
├── bootstrap.sh                      — 初回セットアップ (Homebrew導入→clone→setup実行)
└── setup.sh                          — パッケージインストール・シンボリックリンク作成・macOS設定
```

## その他のルール

- `config/` は `~/.config/` に、`home/` は `~/` にシンボリックリンクされる
- パッケージの追加は `setup.sh` の該当セクション (`install_formula` / `install_cask`) に追記する

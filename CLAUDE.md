# OpenClaw (Docker)

Docker Compose で運用する OpenClaw インスタンス。

## Commands

```bash
docker compose up -d                                          # 起動
docker compose down                                           # 停止
docker compose logs -f                                        # ログ
docker compose --profile cli run --rm openclaw-cli <command>  # CLI
./scripts/oc <command>                                        # CLI (shorthand)
```

## Config

- `config/openclaw.json`: メイン設定（read-only マウント）
- `cron/jobs.json`: cron ジョブ定義（read-only マウント）
- `.env`: 環境変数（トークン、API キー）

## Security

- `cap_drop: ALL`, `read_only: true`, `no-new-privileges`
- Port は `127.0.0.1:18789` にバインド（localhost 限定）
- sandbox mode: `non-main`（メインエージェント以外をサンドボックス化）
- Memory limit: 2GB

## Data Migration

初回セットアップ時は `scripts/migrate.sh` で既存データを移行:

```bash
./scripts/migrate.sh
```

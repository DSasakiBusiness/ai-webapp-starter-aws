# Docker 開発ガイド

## 前提条件

- Docker Desktop がインストール済み（メモリ 4GB 以上を割り当て推奨）

## サービス構成

| サービス | ポート | 説明 |
|---|---|---|
| web | 3000 | Next.js フロントエンド |
| api | 3001 | NestJS バックエンド |
| db | 5432 | PostgreSQL データベース |

## 基本操作

```bash
make up          # 起動
make down        # 停止
make restart     # 再起動
make build       # 再ビルド（キャッシュなし）
make clean       # 全削除（ボリューム含む）
make logs        # ログ表示
```

## Prisma 操作

```bash
make db-migrate   # マイグレーション適用
make db-generate  # Client 生成
make db-seed      # シードデータ投入
make db-studio    # Prisma Studio (GUI)
make db-reset     # 全リセット
```

## テスト

```bash
make test-unit        # ユニット
make test-integration # 統合
make test-e2e         # E2E
```

## トラブルシューティング

| 問題 | 解決方法 |
|---|---|
| ポート競合 | `lsof -i :3000` で占有プロセスを特定 |
| DB 接続エラー | `make logs-db` でログ確認 |
| node_modules 不整合 | `make clean && make build` |
| Prisma Client 古い | `make db-generate` |

## 開発用 / 本番用 Dockerfile の違い

| 項目 | Dockerfile.dev | Dockerfile |
|---|---|---|
| ビルド段階 | シングルステージ | マルチステージ |
| ホットリロード | 有効（ボリュームマウント） | 無効 |
| 最適化 | なし | プロダクション最適化 |
| サイズ | 大きい | 最小限 |

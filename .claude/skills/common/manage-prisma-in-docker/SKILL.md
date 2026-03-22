---
name: manage-prisma-in-docker
description: Docker 環境内で Prisma のマイグレーション・生成・シード・スタジオを操作する手順
---

# Manage Prisma in Docker

## この skill を使う場面

- Docker 環境で Prisma スキーマを変更した場合
- マイグレーションの作成・適用が必要な場合
- シードデータの投入が必要な場合
- DB の状態を GUI で確認したい場合

## 入力前提

- Docker Compose が起動済み
- `apps/api/prisma/schema.prisma` が更新済み

## 実行手順

### Step 1: マイグレーション作成・適用

```bash
# マイグレーション作成（開発環境）
make db-migrate
# 内部: docker compose exec api npx prisma migrate dev --schema=./apps/api/prisma/schema.prisma

# マイグレーション名を指定する場合
docker compose exec api npx prisma migrate dev --name add-users-table --schema=./apps/api/prisma/schema.prisma
```

### Step 2: Prisma Client 再生成

```bash
make db-generate
# 内部: docker compose exec api npx prisma generate --schema=./apps/api/prisma/schema.prisma
```

### Step 3: シードデータ投入

```bash
make db-seed
# 内部: docker compose exec api npx prisma db seed
```

### Step 4: DB リセット（全データ削除 + 再マイグレーション + シード）

```bash
make db-reset
# 内部: docker compose exec api npx prisma migrate reset --schema=./apps/api/prisma/schema.prisma --force
```

### Step 5: Prisma Studio（GUI）

```bash
make db-studio
# 内部: docker compose exec api npx prisma studio --schema=./apps/api/prisma/schema.prisma
# ブラウザで http://localhost:5555 にアクセス
```

### Step 6: DB に直接接続（psql）

```bash
make shell-db
# 内部: docker compose exec db psql -U postgres -d ai_webapp_dev
```

## 判断ルール

- スキーマ変更後 → `make db-migrate` → `make db-generate`
- テストデータが必要 → `make db-seed`
- DB が壊れた → `make db-reset`
- データを確認したい → `make db-studio` または `make shell-db`

## 出力形式

Prisma 操作の実行結果。

## 注意点

- `make db-reset` は全データが削除される。開発環境でのみ使用する
- マイグレーションファイルは Git にコミットする
- マイグレーション名は意味のある名前をつける（例: `add-users-table`）
- 本番環境では `prisma migrate deploy` を使用する（`migrate dev` は使わない）

## 失敗時の扱い

- マイグレーション競合: `prisma migrate resolve --rolled-back [name]` で解決
- DB コンテナが起動していない: `make up` で起動し、ヘルスチェックを待つ
- Prisma Client の型が古い: `make db-generate` で再生成
- シードが失敗: シードスクリプトのエラーを確認し、`upsert` で冪等性を保証する

---
name: implement-prisma-schema
description: Prisma スキーマの定義、マイグレーション、シード作成の手順
---

# Implement Prisma Schema

## この skill を使う場面

- 新しいデータモデルを定義する場合
- 既存のスキーマを変更する場合
- シードデータを作成する場合

## 入力前提

- solution-architect が定義したデータモデル方針
- write-api-contract の API 契約（入出力型から逆算）
- 既存の `prisma/schema.prisma`

## 実行手順

### Step 1: スキーマ定義

`apps/api/prisma/schema.prisma` にモデルを追加する:

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  role      Role     @default(USER)
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@map("users")
}

enum Role {
  USER
  ADMIN
}
```

### Step 2: マイグレーション作成

```bash
# Docker 経由
make db-migrate
# ローカル
npx prisma migrate dev --name [migration-name] --schema=apps/api/prisma/schema.prisma
```

マイグレーション名の規則:
- `add-[table]-table`（新規テーブル）
- `add-[column]-to-[table]`（カラム追加）
- `rename-[old]-to-[new]-in-[table]`（リネーム）

### Step 3: Prisma Client 生成

```bash
# Docker 経由
make db-generate
# ローカル
npx prisma generate --schema=apps/api/prisma/schema.prisma
```

### Step 4: シードデータ作成

`apps/api/prisma/seed.ts`:

```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // ユーザーシード
  const admin = await prisma.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: {
      email: 'admin@example.com',
      name: 'Admin User',
      role: 'ADMIN',
    },
  });

  console.log('Seed completed:', { admin });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

### Step 5: スキーマ検証

```bash
npx prisma validate --schema=apps/api/prisma/schema.prisma
npx prisma format --schema=apps/api/prisma/schema.prisma
```

## 判断ルール

- カラム追加は基本的にオプショナル(`?`)で追加し、既存データへの影響を避ける
- 破壊的変更（カラム削除、型変更）は段階的に行う:
  1. 新カラムを追加
  2. データを移行
  3. アプリケーションを新カラムに切り替え
  4. 旧カラムを削除
- インデックスはクエリパターンに基づいて追加する
- リレーションは外部キー制約を使用する

## 出力形式

- `prisma/schema.prisma` の更新内容
- マイグレーションファイル（自動生成）
- `prisma/seed.ts` の更新内容

## 注意点

- `@map` でテーブル名を snake_case にする
- `cuid()` をデフォルト ID 戦略として使う
- `createdAt` と `updatedAt` を全テーブルに付与する
- 本番環境では `prisma migrate deploy`、開発では `prisma migrate dev` を使う
- マイグレーションファイルは手動で編集しない

## 失敗時の扱い

- マイグレーション競合: `prisma migrate resolve` で状態を修正する
- 型生成エラー: `prisma generate` を再実行する
- シードの重複: `upsert` を使い、冪等性を保証する

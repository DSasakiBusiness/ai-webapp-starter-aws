---
name: write-api-contract
description: API エンドポイントの契約（入出力型、ステータスコード）を定義する手順
---

# Write API Contract

## この skill を使う場面

- 新しい API エンドポイントを設計する場合
- フロントエンドとバックエンドの境界を定義する場合

## 入力前提

- product-manager の要件定義
- solution-architect のアーキテクチャ方針

## 実行手順

### Step 1: エンドポイント一覧

```markdown
| Method | Path | 説明 | 認証 |
|---|---|---|---|
| GET | /api/v1/items | アイテム一覧取得 | 必要 |
| POST | /api/v1/items | アイテム作成 | 必要 |
| GET | /api/v1/items/:id | アイテム詳細取得 | 必要 |
| PUT | /api/v1/items/:id | アイテム更新 | 必要 |
| DELETE | /api/v1/items/:id | アイテム削除 | 必要 |
```

### Step 2: 型定義

`packages/shared/src/types/` に共通型を定義する:

```typescript
// packages/shared/src/types/item.ts
export interface Item {
  id: string;
  name: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateItemRequest {
  name: string;
}

export interface ApiResponse<T> {
  data: T;
  meta?: { total: number; page: number; limit: number };
}

export interface ApiError {
  statusCode: number;
  message: string;
  error: string;
}
```

### Step 3: ステータスコード定義

| コード | 用途 |
|---|---|
| 200 | 成功（取得・更新） |
| 201 | 成功（作成） |
| 204 | 成功（削除） |
| 400 | バリデーションエラー |
| 401 | 未認証 |
| 403 | 権限不足 |
| 404 | リソース不存在 |
| 500 | サーバーエラー |

### Step 4: frontend-developer と backend-developer に共有

定義した型を `packages/shared` にエクスポートし、両側で使用する。

## 判断ルール

- CRUD 操作 → RESTful 標準に従う
- AI 機能 → ストリーミング対応の場合 SSE エンドポイントを追加
- ページネーション → `?page=1&limit=20` 形式を標準とする

## 出力形式

API 契約ドキュメント + `packages/shared` の型定義ファイル。

## 注意点

- 型定義はフロントエンドとバックエンドで同一のものを使う
- レスポンス形式は統一する

## 失敗時の扱い

- 要件が不明確: product-manager に確認する
- 型が複雑すぎる: solution-architect と簡素化を検討する

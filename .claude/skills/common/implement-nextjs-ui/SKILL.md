---
name: implement-nextjs-ui
description: Next.js (App Router) でUI コンポーネント・ページを実装する手順
---

# Implement Next.js UI

## この skill を使う場面

- 新しいページやコンポーネントを Next.js で実装する場合
- 既存の UI を改修する場合
- AI 機能のフロントエンド部分を実装する場合

## 入力前提

- generate-ui-spec で作成された UI 仕様書
- write-api-contract で定義された API 契約
- tdd-coach が定義した受け入れ条件

## 実行手順

### Step 1: ファイル構成の決定

```
apps/web/src/
├── app/
│   └── [route]/
│       ├── page.tsx          # ページコンポーネント（Server Component）
│       ├── layout.tsx        # レイアウト
│       ├── loading.tsx       # ローディング UI
│       └── error.tsx         # エラー UI
├── components/
│   └── [ComponentName]/
│       ├── [ComponentName].tsx       # コンポーネント本体
│       ├── [ComponentName].test.tsx  # テスト
│       └── [ComponentName].module.css # スタイル（CSS Modules の場合）
└── lib/
    └── api/                  # API クライアント
```

### Step 2: テストファーストで実装

1. コンポーネントの期待動作を定義する
2. React Testing Library で失敗するテストを書く
3. 最小限の実装でテストを通す
4. リファクタリングする

```typescript
// [ComponentName].test.tsx
import { render, screen } from '@testing-library/react';
import { ComponentName } from './ComponentName';

describe('ComponentName', () => {
  it('should render [期待表示] when [条件]', () => {
    render(<ComponentName prop={value} />);
    expect(screen.getByTestId('element-id')).toBeInTheDocument();
  });
});
```

### Step 3: Server Component / Client Component の判断

- **Server Component（デフォルト）**: データフェッチ、静的表示、SEO が重要なページ
- **Client Component（'use client'）**: イベントハンドラ、useState/useEffect、ブラウザ API

### Step 4: API クライアントの実装

```typescript
// lib/api/client.ts
const API_BASE = process.env.NEXT_PUBLIC_API_URL;

export async function fetchData<T>(path: string): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`);
  if (!res.ok) {
    throw new Error(`API Error: ${res.status}`);
  }
  return res.json();
}
```

### Step 5: ローディング・エラー・空状態の実装

全ページに以下の 3 状態を実装する:
- `loading.tsx`: Skeleton UI またはスピナー
- `error.tsx`: エラーメッセージと再試行ボタン
- 空状態: データがない場合の案内表示

### Step 6: AI 機能 UI の実装（該当する場合）

- ストリーミング表示: Server-Sent Events を受信し、逐次レンダリング
- ローディング表示: AI が考えている間のプログレス表示
- エラー表示: AI 応答エラー時のフォールバック表示
- 再試行: ユーザーが再生成できるボタン

## 判断ルール

- コンポーネントが 100 行を超える場合: 分割を検討する
- 同じ UI パターンが 3 箇所以上で使われる場合: 共通コンポーネントに抽出する
- API 呼び出しが 2 つ以上ある場合: カスタムフックに抽出する

## 出力形式

- コンポーネントファイル（`.tsx`）
- テストファイル（`.test.tsx`）
- スタイルファイル（`.module.css`、必要な場合）
- 型定義（`packages/shared` に共有型がある場合はそれを使用）

## 注意点

- `any` 型禁止、Props の型定義必須
- `dangerouslySetInnerHTML` 禁止（XSS 対策）
- テスト用に `data-testid` を主要な要素に付与する
- 画像は `next/image` を使用する
- `console.log` をコミットしない

## 失敗時の扱い

- API が未完成: モックデータでフロントエンドを先行実装し、API 完成後に差し替える
- デザインが未確定: ワイヤーフレームレベルで実装し、デザイン確定後に調整する
- 型の不整合: `packages/shared` の型定義を更新し、フロントエンドとバックエンドで同期する

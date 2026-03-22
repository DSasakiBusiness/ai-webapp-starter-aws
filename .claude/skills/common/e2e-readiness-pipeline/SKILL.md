---
name: e2e-readiness-pipeline
description: Playwright E2E テストの準備・設計・安定化の手順
---

# E2E Readiness Pipeline

## この skill を使う場面

- E2E テストスイートを新規に構築する場合
- E2E テストのシナリオを追加する場合
- flaky な E2E テストを安定化する場合

## 入力前提

- product-manager が定義したユーザーフロー
- テスト対象の web / api がDockerで起動可能であること
- テスト用のシードデータ

## 実行手順

### Step 1: 環境準備

```bash
# Playwright インストール
npx playwright install --with-deps chromium

# テスト用サービス起動
make up
make db-migrate
make db-seed
```

### Step 2: 認証セットアップ

```typescript
// tests/e2e/setup/auth.setup.ts
import { test as setup } from '@playwright/test';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByTestId('email-input').fill('admin@example.com');
  await page.getByTestId('password-input').fill('password');
  await page.getByTestId('login-button').click();
  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: 'tests/e2e/.auth/user.json' });
});
```

### Step 3: シナリオ設計

主要フローをカバーする:

1. **認証フロー**: ログイン / ログアウト / 認証エラー
2. **CRUD フロー**: 一覧 / 作成 / 詳細 / 更新 / 削除
3. **AI 機能フロー**: 入力 / 生成中表示 / 結果表示 / エラー / 再試行
4. **権限制御**: 未認証アクセス拒否 / 権限不足の操作拒否
5. **エラー表示**: 404 / 500 / ネットワークエラー

### Step 4: テスト実装

```typescript
// tests/e2e/specs/crud.spec.ts
import { test, expect } from '@playwright/test';

test.describe('CRUD Operations', () => {
  test.use({ storageState: 'tests/e2e/.auth/user.json' });

  test('should create a new item', async ({ page }) => {
    await page.goto('/items');
    await page.getByTestId('create-button').click();
    await page.getByTestId('name-input').fill('Test Item');
    await page.getByTestId('submit-button').click();
    await expect(page.getByTestId('success-message')).toBeVisible();
  });
});
```

### Step 5: 安定化

- `data-testid` ベースのセレクタを使う（CSS クラスに依存しない）
- `waitForSelector` / `waitForURL` を使い、固定 `sleep` を避ける
- テストデータは各テストで独立化する
- ネットワーク待ちには `waitForResponse` を使う
- スクリーンショットは失敗時のみ撮影する

### Step 6: CI 統合

GitHub Actions で Docker 起動 → E2E 実行 → レポートアップロードの流れを構成する。

## 判断ルール

- テスト実行時間が 5 分を超える → 並列実行（`workers: 4`）を検討
- 同じセレクタが 3 箇所以上 → ヘルパー関数に抽出
- AI 機能のE2E → レスポンス構造のみ検証し、文言一致を避ける
- flaky テスト → 3 回連続成功するまで安定化する

## 出力形式

- Playwright 設定ファイル
- 認証セットアップファイル
- テストスペックファイル
- ヘルパー関数

## 注意点

- テスト文言のハードコードを避ける（国際化対応を阻害する）
- テスト間でデータを共有しない
- 並列実行時のデータ競合を避ける
- Docker 環境での起動を前提にする

## 失敗時の扱い

- セレクタが見つからない: frontend-developer に data-testid の追加を依頼
- タイムアウト: サーバーの起動完了を待つヘルスチェックを追加
- 認証失敗: シードデータとログイン情報の整合性を確認

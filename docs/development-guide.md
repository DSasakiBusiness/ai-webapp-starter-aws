# 開発ガイド

## 開発ワークフロー

### 新機能の開発フロー

```
1. 要件確認     → product-manager が受け入れ条件を定義
2. 設計         → solution-architect がアーキテクチャを検討
3. API 契約定義 → write-api-contract で型を定義
4. テスト作成   → tdd-coach の方針に従い Red テストを先に書く
5. 実装         → テストを通す最小限の実装（Green）
6. リファクタ   → テストが通る状態でコード改善
7. 統合テスト   → DB を使った結合検証
8. E2E テスト   → Playwright でユーザーフロー検証
9. レビュー     → qa-reviewer + security-reviewer
10. マージ      → CI 全パス後にマージ
```

### TDD サイクル（Red → Green → Refactor）

```bash
# 1. テストを書く（Red: 失敗することを確認）
make test-unit  # → FAIL

# 2. 最小限の実装を書く（Green: テストが通ることを確認）
make test-unit  # → PASS

# 3. リファクタリング（テストが引き続き通ることを確認）
make test-unit  # → PASS
```

## ファイル命名規約

| 種類 | パターン | 例 |
|---|---|---|
| NestJS Module | `[name].module.ts` | `users.module.ts` |
| NestJS Controller | `[name].controller.ts` | `users.controller.ts` |
| NestJS Service | `[name].service.ts` | `users.service.ts` |
| NestJS DTO | `[name].dto.ts` | `create-user.dto.ts` |
| Unit Test (API) | `[name].spec.ts` | `users.service.spec.ts` |
| Integration Test | `[name].integration.ts` | `users.integration.ts` |
| React Component | `[Name].tsx` | `UserCard.tsx` |
| Unit Test (Web) | `[name].test.tsx` | `page.test.tsx` |
| E2E Test | `[name].spec.ts` | `auth.spec.ts` |
| Prompt Template | `[name].prompt.ts` | `summarize.prompt.ts` |

## テストの書き方

### API ユニットテスト

```typescript
// src/users/users.service.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from '../prisma/prisma.service';

describe('UsersService', () => {
  let service: UsersService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: PrismaService,
          useValue: {
            user: {
              findMany: jest.fn(),
              findUnique: jest.fn(),
              create: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  describe('findAll', () => {
    it('should return an array of users', async () => {
      const mockUsers = [
        { id: '1', email: 'a@b.com', name: 'Test', role: 'USER' },
      ];
      jest.spyOn(prisma.user, 'findMany').mockResolvedValue(mockUsers as any);

      const result = await service.findAll();

      expect(result).toEqual(mockUsers);
    });
  });
});
```

### Web ユニットテスト

```tsx
// src/components/UserCard.test.tsx
import { render, screen } from '@testing-library/react';
import { UserCard } from './UserCard';

describe('UserCard', () => {
  it('should render user name', () => {
    render(<UserCard user={{ id: '1', name: 'Test', email: 'a@b.com' }} />);

    expect(screen.getByText('Test')).toBeInTheDocument();
  });
});
```

### E2E テスト

```typescript
// tests/e2e/specs/health.spec.ts
import { test, expect } from '@playwright/test';

test('should display the top page', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('h1')).toBeVisible();
});
```

## API Client の使い方

```typescript
import { apiClient, ApiClientError } from '@/lib/api-client';
import type { ApiResponse, User } from 'shared';

// GET
const response = await apiClient.get<ApiResponse<User[]>>('/users', {
  params: { page: 1, limit: 20 },
});

// POST
const newUser = await apiClient.post<ApiResponse<User>>('/users', {
  body: { email: 'user@example.com', name: 'New User' },
});

// エラーハンドリング
try {
  await apiClient.get('/protected-resource');
} catch (error) {
  if (error instanceof ApiClientError) {
    console.error(`${error.statusCode}: ${error.message}`);
  }
}
```

## Docker での Prisma 操作

```bash
# スキーマ変更後の流れ
# 1. schema.prisma を編集
# 2. マイグレーション作成
make db-migrate

# 3. Prisma Client 再生成（スキーマ変更がある場合）
make db-generate

# 4. シードデータ更新が必要な場合
make db-seed

# DB を完全にやり直したい場合
make db-reset
```

## 新しいモジュールの追加手順

### API 側

```bash
# 1. ディレクトリ作成
mkdir -p apps/api/src/users

# 2. ファイル作成
# - users.module.ts
# - users.controller.ts
# - users.service.ts
# - users.controller.spec.ts  (TDD: テスト先)
# - users.service.spec.ts     (TDD: テスト先)
# - dto/create-user.dto.ts
# - dto/update-user.dto.ts

# 3. app.module.ts に UsersModule を import
```

### Web 側

```bash
# 1. ページ作成
mkdir -p apps/web/src/app/users

# 2. ファイル作成
# - page.tsx
# - page.test.tsx  (TDD: テスト先)
# - loading.tsx
# - error.tsx
```

## トラブルシューティング

| 問題 | 解決 |
|---|---|
| Docker 起動しない | `make clean && make build && make up` |
| ポート競合 | `lsof -i :3000` で占有プロセスを特定して終了 |
| DB 接続エラー | `make logs-db` で PostgreSQL のログを確認 |
| Prisma Client が古い | `make db-generate` で再生成 |
| node_modules 不整合 | `make clean && make build` で再構築 |
| テストが flaky | `make logs` でサービスの状態を確認 |
| E2E テスト失敗 | `make check` でサービス起動を確認してから再実行 |
| API が 500 を返す | `make logs-api` でスタックトレースを確認 |

# ユニットテスト方針

## 概要

ユニットテストは関数・クラス単体のロジックを検証する。外部依存（DB、API、ファイルシステム）はモックで置き換える。

## 対象

- ビジネスロジック（サービスクラスのメソッド）
- ユーティリティ関数
- React コンポーネント（React Testing Library）
- バリデーション（DTO）
- 型ガード関数

## テストフレームワーク

- **Backend**: Jest + jest-mock-extended
- **Frontend**: Jest + React Testing Library + @testing-library/jest-dom

## 規約

### ファイル配置
- テストファイルは対象ファイルの隣に配置する
- Backend: `[name].spec.ts`
- Frontend: `[name].test.tsx`

### 命名規則
```typescript
describe('[テスト対象]', () => {
  describe('[メソッド名]', () => {
    it('should [期待動作] when [条件]', () => {
      // Arrange - 準備
      // Act - 実行
      // Assert - 検証
    });
  });
});
```

### カバレッジ目標
- ライン: 80% 以上
- ブランチ: 70% 以上

## AI 機能のユニットテスト

- LLM 呼び出しはモック化する
- 出力の構造（JSON Schema 準拠）を検証する
- 厳密な文字列一致は使わない
- エラーハンドリング（レート制限、タイムアウト）を検証する
- トークン使用量の計算ロジックを検証する

## 実行方法

```bash
# ローカル
npm run test:unit

# Docker 経由
make test-unit
```

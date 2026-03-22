# AI 統合ガイド

## LLM Provider パターン

LLM プロバイダーを交換可能にするため、インターフェースで抽象化する:

```typescript
interface LlmProvider {
  chat(messages: ChatMessage[], options?: LlmOptions): Promise<AiResponse>;
  chatStream(messages: ChatMessage[], options?: LlmOptions): AsyncIterable<string>;
}
```

## 対応プロバイダー

- **OpenAI**: GPT-4o, GPT-4o-mini
- **Anthropic**: Claude 3.5 Sonnet, Claude 3 Haiku

環境変数 `LLM_PROVIDER` で切り替え可能。

## プロンプト管理

プロンプトは `.prompt.ts` ファイルとしてバージョン管理する。テンプレート化して入力を注入する形式とする。

## ストリーミング

レスポンス生成に 3 秒以上かかる場合はストリーミング（SSE）を使用する。フロントエンドは逐次レンダリングする。

## エラーハンドリング

- レート制限: exponential backoff（最大 3 回）
- タイムアウト: 30 秒上限
- API キー無効: リトライせずエラー返却
- 不正 JSON: Zod バリデーション + リトライ

## セキュリティ

- プロンプトインジェクション対策: ユーザー入力のサニタイズ
- 出力フィルタリング: PII 検出
- API キー管理: Secrets Manager 経由

## RAG パイプライン（オプション）

```
ユーザークエリ → Embedding → ベクトル検索 → コンテキスト組み立て → LLM 生成 → 引用付き回答
```

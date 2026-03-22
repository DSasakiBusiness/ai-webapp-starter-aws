---
name: integrate-llm-feature
description: LLM プロバイダーを交換可能な設計で統合する手順
---

# Integrate LLM Feature

## この skill を使う場面

- アプリケーションに LLM 機能を追加する場合
- 既存の LLM 統合を別プロバイダーに切り替える場合
- LLM 出力のストリーミングを実装する場合

## 入力前提

- clarify-ai-requirements の出力（AI 要件定義）
- solution-architect が定義した AI 統合パターン（同期/非同期/ストリーミング）
- LLM プロバイダーの API キー

## 実行手順

### Step 1: Provider インターフェース定義

```typescript
// modules/ai/interfaces/llm-provider.interface.ts
export interface LlmMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface LlmResponse {
  content: string;
  model: string;
  usage: { promptTokens: number; completionTokens: number; totalTokens: number };
}

export interface LlmProvider {
  chat(messages: LlmMessage[], options?: LlmOptions): Promise<LlmResponse>;
  chatStream(messages: LlmMessage[], options?: LlmOptions): AsyncIterable<string>;
}

export interface LlmOptions {
  model?: string;
  maxTokens?: number;
  temperature?: number;
}
```

### Step 2: プロバイダー実装

OpenAI と Anthropic の両方を実装し、環境変数で切り替え可能にする。

### Step 3: プロンプトテンプレート管理

```typescript
// modules/ai/prompts/[feature].prompt.ts
export const featurePrompt = {
  system: `あなたは[役割]です。以下のルールに従ってください:
- ルール1
- ルール2`,
  buildUserMessage: (input: FeatureInput): string => {
    return `[入力データの構造化]`;
  },
};
```

### Step 4: AI サービス実装

NestJS Module として実装し、DI で注入可能にする。エラーハンドリング（レート制限、タイムアウト）と再試行ロジック（exponential backoff、最大 3 回）を含める。

### Step 5: ストリーミング実装（該当する場合）

Server-Sent Events (SSE) でフロントエンドにストリーミング配信する。

### Step 6: テスト

LLM モックを使い、構造評価で検証する。厳密文字一致は使わない。

## 判断ルール

- レスポンス生成に 3 秒以上かかる見込み → ストリーミング必須
- 固定的な出力が必要 → temperature を 0 に設定
- コスト制約がある → トークン使用量のログと上限設定を組み込む
- 複数モデルを比較したい → A/B テスト可能な構造にする

## 出力形式

- LLM Provider インターフェースと実装
- プロンプトテンプレートファイル
- AI サービスモジュール
- テストファイル

## 注意点

- API キーはハードコードせず環境変数から取得する
- レスポンスの型を Zod でバリデーションする
- トークン使用量をログに記録する
- プロンプトインジェクション対策としてユーザー入力をサニタイズする

## 失敗時の扱い

- API キーが無効: 即座にエラーを返し、リトライしない
- レート制限: exponential backoff で再試行（最大 3 回）
- タイムアウト: 30 秒でタイムアウトし、ユーザーに再試行を促す
- 不正な JSON レスポンス: パースエラーをキャッチし、再試行する

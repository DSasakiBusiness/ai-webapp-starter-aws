# AI エージェントパターン リファレンス

> [awesome-agentic-patterns](https://github.com/nibzard/awesome-agentic-patterns) から AI SaaS 開発に直結する 8 パターンを厳選し、本プロジェクト向けに実装ガイドラインとしてまとめたもの。

---

## 1. Structured Output Specification（構造化出力仕様）

**概要**: LLM の出力を JSON Schema / Zod で厳密に定義し、パース→バリデーション→リトライの一貫フローを強制する。

**本プロジェクトでの適用**:

```typescript
// apps/api/src/ai/schemas/chat-response.schema.ts
import { z } from 'zod';

export const ChatResponseSchema = z.object({
  answer: z.string().min(1),
  confidence: z.number().min(0).max(1),
  sources: z.array(z.object({
    title: z.string(),
    url: z.string().url().optional(),
  })).optional(),
  metadata: z.object({
    model: z.string(),
    tokensUsed: z.number(),
    latencyMs: z.number(),
  }),
});

export type ChatResponse = z.infer<typeof ChatResponseSchema>;
```

**実装ルール**:
- 全 AI 出力に Zod スキーマを定義する
- パース失敗時は最大 2 回リトライ（プロンプトにエラー内容をフィードバック）
- 型定義は `packages/shared` に配置し、フロントエンドと共有する

---

## 2. Plan-then-Execute（計画→実行分離）

**概要**: 複雑なタスクを「計画フェーズ」と「実行フェーズ」に分離し、計画をユーザーに確認させてから実行する。

**本プロジェクトでの適用**:

```typescript
// Step 1: 計画生成（軽量モデル可）
const plan = await aiService.generatePlan(userRequest);
// → { steps: ["検索", "要約", "回答生成"], estimatedTokens: 3000 }

// Step 2: ユーザー確認（オプション）
// → フロントエンドで計画を表示し、承認を待つ

// Step 3: 計画に従って逐次実行
for (const step of plan.steps) {
  const result = await aiService.executeStep(step, context);
  context = { ...context, [step.id]: result };
}
```

**実装ルール**:
- 推定トークン数が 2,000 を超えるタスクでは計画フェーズを挟む
- 計画は JSON で構造化し、フロントエンドでステップ表示可能にする
- 各ステップの実行結果を次のステップのコンテキストとして渡す

---

## 3. Budget-Aware Model Routing（コスト意識モデル選択）

**概要**: リクエストの複雑さに応じて最適なモデルを動的に選択し、コスト上限を設ける。

**本プロジェクトでの適用**:

```typescript
// apps/api/src/ai/services/model-router.service.ts
interface ModelRoute {
  model: string;
  costPer1kTokens: number;
  maxTokens: number;
  suitableFor: ('simple' | 'complex' | 'creative')[];
}

const ROUTES: ModelRoute[] = [
  { model: 'gpt-4o-mini', costPer1kTokens: 0.00015, maxTokens: 4096, suitableFor: ['simple'] },
  { model: 'gpt-4o', costPer1kTokens: 0.005, maxTokens: 8192, suitableFor: ['complex', 'creative'] },
  { model: 'claude-3-5-sonnet', costPer1kTokens: 0.003, maxTokens: 8192, suitableFor: ['complex'] },
];

// 分類 → ルーティング → コスト上限チェック
async selectModel(request: AiRequest, dailyBudgetRemaining: number): Promise<ModelRoute> {
  const complexity = this.classifyComplexity(request);
  const candidates = ROUTES.filter(r => r.suitableFor.includes(complexity));
  return candidates.find(r => this.estimateCost(r, request) < dailyBudgetRemaining)
    ?? this.getFallbackModel();
}
```

**実装ルール**:
- 日次コスト上限を環境変数 `LLM_DAILY_BUDGET_USD` で設定
- 上限到達時はキューイングまたは軽量モデルにフォールバック
- コスト実績は DB に記録し、ダッシュボードで可視化可能にする

---

## 4. Failover-Aware Model Fallback（障害対応フォールバック）

**概要**: プライマリモデルの障害時に、自動でセカンダリモデルに切り替える。

**本プロジェクトでの適用**:

```typescript
// apps/api/src/ai/services/llm-provider.service.ts
const FALLBACK_CHAIN = ['gpt-4o', 'claude-3-5-sonnet', 'gpt-4o-mini'];

async callWithFallback(prompt: string, options: LlmOptions): Promise<LlmResponse> {
  for (const model of FALLBACK_CHAIN) {
    try {
      return await this.call(model, prompt, options);
    } catch (error) {
      if (this.isTransient(error)) {
        this.logger.warn(`${model} failed, trying next: ${error.message}`);
        continue;
      }
      throw error;  // 非一時的エラーは即座に上位へ
    }
  }
  return this.getGracefulDegradationResponse();
}
```

**実装ルール**:
- フォールバックチェーンは環境変数 `LLM_FALLBACK_CHAIN` で設定
- 一時的エラー（429, 503, タイムアウト）のみフォールバック対象
- フォールバック発生はメトリクスとして記録する

---

## 5. Self-Critique Evaluator Loop（自己評価ループ）

**概要**: LLM の出力を別の LLM（または同じ LLM の別呼び出し）で評価し、品質基準を満たすまで再生成する。

**本プロジェクトでの適用**:

```typescript
// apps/api/src/ai/services/quality-evaluator.service.ts
async generateWithQualityCheck(prompt: string, minScore: number = 0.7): Promise<AiOutput> {
  const MAX_RETRIES = 2;

  for (let i = 0; i <= MAX_RETRIES; i++) {
    const output = await this.llm.generate(prompt);
    const evaluation = await this.evaluate(output, prompt);

    if (evaluation.score >= minScore) {
      return { ...output, qualityScore: evaluation.score };
    }

    // 評価フィードバックをプロンプトに追加して再生成
    prompt = this.appendFeedback(prompt, evaluation.feedback);
  }

  return { ...output, qualityScore: evaluation.score, belowThreshold: true };
}
```

**実装ルール**:
- 評価基準: 関連性、正確性、完全性の 3 軸スコア（0.0-1.0）
- 最大リトライ回数を超えた場合は低品質フラグ付きで返却
- 評価に使う LLM は軽量モデル（gpt-4o-mini）で十分

---

## 6. Hook-Based Safety Guard Rails（フック型安全ガードレール）

**概要**: AI パイプラインの入出力にフック（ミドルウェア）を挟み、安全性チェックを一貫して適用する。

**本プロジェクトでの適用**:

```typescript
// apps/api/src/ai/guards/ai-safety.guard.ts
interface AiGuard {
  name: string;
  phase: 'pre' | 'post';
  check(content: string): Promise<GuardResult>;
}

const guards: AiGuard[] = [
  { name: 'prompt-injection', phase: 'pre', check: detectPromptInjection },
  { name: 'pii-filter', phase: 'pre', check: detectPII },
  { name: 'output-toxicity', phase: 'post', check: checkToxicity },
  { name: 'output-hallucination', phase: 'post', check: checkFactualConsistency },
];

// パイプラインでの適用
async processWithGuards(input: string): Promise<string> {
  // Pre-guards
  for (const guard of guards.filter(g => g.phase === 'pre')) {
    const result = await guard.check(input);
    if (!result.passed) throw new AiSafetyError(guard.name, result.reason);
  }

  const output = await this.llm.generate(input);

  // Post-guards
  for (const guard of guards.filter(g => g.phase === 'post')) {
    const result = await guard.check(output);
    if (!result.passed) {
      this.logger.warn(`Post-guard ${guard.name} failed: ${result.reason}`);
      return this.getSafeResponse(guard.name);
    }
  }

  return output;
}
```

**実装ルール**:
- ガードは NestJS の Guard/Interceptor パターンで実装
- pre ガードの失敗は 400 エラー、post ガードの失敗は安全なフォールバック応答
- ガード結果は全件ログに記録（監査トレイル）

---

## 7. LLM Observability（LLM 可観測性）

**概要**: LLM 呼び出しのメトリクス（レイテンシ、トークン数、コスト、成功率）を体系的に記録・可視化する。

**本プロジェクトでの適用**:

```typescript
// apps/api/src/ai/interceptors/llm-metrics.interceptor.ts
interface LlmMetrics {
  requestId: string;
  model: string;
  promptTokens: number;
  completionTokens: number;
  totalTokens: number;
  latencyMs: number;
  estimatedCostUsd: number;
  success: boolean;
  errorType?: string;
  timestamp: Date;
}

// 全 LLM 呼び出しで自動記録
async recordMetrics(call: () => Promise<LlmResponse>): Promise<LlmResponse> {
  const start = Date.now();
  try {
    const response = await call();
    await this.save({
      ...this.extractMetrics(response),
      latencyMs: Date.now() - start,
      success: true,
    });
    return response;
  } catch (error) {
    await this.save({
      latencyMs: Date.now() - start,
      success: false,
      errorType: error.constructor.name,
    });
    throw error;
  }
}
```

**実装ルール**:
- メトリクスは Prisma モデル `LlmUsageLog` に保存
- 日次サマリーを集計する cron ジョブを用意
- API レスポンスの `metadata` フィールドにトークン数・モデル名を含める

---

## 8. Prompt Caching via Exact Prefix Preservation（プロンプトキャッシュ）

**概要**: プロンプトの共通プレフィックス（システムプロンプト部分）を不変に保ち、LLM プロバイダーのプロンプトキャッシュを最大限活用する。

**本プロジェクトでの適用**:

```typescript
// apps/api/src/ai/prompts/base-system.prompt.ts
// ⚠ このプレフィックスは変更しないこと（キャッシュヒット率に直結）
const SYSTEM_PREFIX = `あなたは...（固定システムプロンプト）`;

// 可変部分は末尾に追加
function buildPrompt(systemPrefix: string, context: string, userMessage: string): Message[] {
  return [
    { role: 'system', content: systemPrefix },  // ← 固定（キャッシュ対象）
    { role: 'system', content: context },         // ← 可変
    { role: 'user', content: userMessage },       // ← 可変
  ];
}
```

**実装ルール**:
- システムプロンプトは `.prompt.ts` ファイルで管理し、変更時はバージョニングする
- 固定部分と可変部分を明確に分離する
- Anthropic の場合は `cache_control` ブレークポイントを活用する

---

## 統合アーキテクチャ

```
ユーザーリクエスト
    │
    ▼
┌──────────────┐
│ Pre-Guards   │ ← Pattern 6: Safety Guard Rails
│ (入力検証)   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Plan Phase   │ ← Pattern 2: Plan-then-Execute
│ (計画生成)   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Model Router │ ← Pattern 3: Budget-Aware Routing
│              │ ← Pattern 4: Failover Fallback
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ LLM Call     │ ← Pattern 8: Prompt Caching
│ + Metrics    │ ← Pattern 7: Observability
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Output Parse │ ← Pattern 1: Structured Output
│ + Validate   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Quality Eval │ ← Pattern 5: Self-Critique Loop
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Post-Guards  │ ← Pattern 6: Safety Guard Rails
│ (出力検証)   │
└──────┬───────┘
       │
       ▼
   レスポンス
```

---

## 参考元

- [awesome-agentic-patterns](https://github.com/nibzard/awesome-agentic-patterns) — MIT License
- 各パターンの原文ドキュメントについては上記リポジトリの `patterns/` ディレクトリを参照

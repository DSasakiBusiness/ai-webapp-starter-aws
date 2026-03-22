# AI Webapp Starter AWS - プロジェクト横断ルール

## リポジトリの目的

AI 特化 Web サービスを迅速に立ち上げるためのスターターリポジトリ。
Next.js + NestJS + Prisma + LLM の構成で、Docker ベースのローカル開発と AWS デプロイを前提とする。

## 技術スタック

- **Frontend**: Next.js (App Router, React Server Components)
- **Backend**: NestJS (TypeScript, Module-based)
- **ORM**: Prisma (PostgreSQL)
- **AI**: OpenAI SDK / Anthropic SDK (交換可能な Provider パターン)
- **RAG**: Embedding + Vector DB (オプション)
- **Test**: Jest (unit/integration) + Playwright (E2E)
- **CI/CD**: GitHub Actions
- **Infra**: AWS (App Runner or ECS/Fargate, RDS, Secrets Manager, CloudWatch)
- **Local Dev**: Docker / Docker Compose

## Agent の使い分け

このプロジェクトでは以下の agent を使い分ける。agent は「判断する存在」であり、具体的な作業手順は skill に委譲する。

### 判断フロー

```
product-manager → solution-architect → 各 developer → tdd-coach → qa-reviewer → e2e-tester → security-reviewer → aws-platform-engineer
```

### 各 agent の管轄

| Agent | 管轄 | 参照先 |
|---|---|---|
| product-manager | 要件定義・優先度・スコープ | `.claude/agents/product/` |
| solution-architect | 全体設計・責務境界・非機能要件 | `.claude/agents/engineering/` |
| frontend-developer | Next.js UI 実装 | `.claude/agents/engineering/` |
| backend-developer | NestJS API 実装 | `.claude/agents/engineering/` |
| ai-engineer | LLM/RAG 統合 | `.claude/agents/engineering/` |
| qa-reviewer | コードレビュー・品質判定 | `.claude/agents/testing/` |
| tdd-coach | TDD サイクル監督 | `.claude/agents/testing/` |
| e2e-tester | E2E テスト設計・実行 | `.claude/agents/testing/` |
| security-reviewer | セキュリティレビュー | `.claude/agents/testing/` |
| aws-platform-engineer | AWS 設計・デプロイ・監視 | `.claude/agents/aws/` |

### 委譲ルール

- 要件が曖昧な場合 → product-manager に差し戻す
- アーキテクチャ変更を伴う場合 → solution-architect に確認する
- AI 機能の変更 → ai-engineer が担当する（frontend-developer / backend-developer は触らない）
- AWS 固有の判断 → aws-platform-engineer に閉じる（他の agent は AWS 直接操作しない）
- テスト方針の変更 → tdd-coach に確認する

## TDD の原則

全ての機能開発は TDD サイクルに従う。

### Red → Green → Refactor

1. **Red**: 受け入れ条件を定義し、失敗するテストを先に書く
2. **Green**: テストを通す最小限の実装を行う
3. **Refactor**: テストが通る状態を維持しながらリファクタリングする

### テストを書く前に確認すること

- 受け入れ条件が明文化されているか
- テストの種類（unit / integration / E2E）が適切か
- テストが他のテストに依存していないか

### テストを書く際の禁止事項

- 実装と同時にテストを書くこと（テストが先）
- テストなしでコードをマージすること
- テストを通すためだけの不自然な実装をすること

## Unit / Integration / E2E の使い分け

| 種類 | 対象 | 実行環境 | 特徴 |
|---|---|---|---|
| Unit | 関数・クラス単体 | モック環境 | 高速・独立・大量に実行 |
| Integration | モジュール間連携 | DB 含む | サービス間の契約検証 |
| E2E | ユーザーフロー全体 | ブラウザ | 実動作の最終確認 |

### 判断基準

- ビジネスロジックの単体検証 → Unit
- DB アクセスを含む処理の検証 → Integration
- ユーザー操作のフロー検証 → E2E
- API の入出力契約の検証 → Integration
- UI コンポーネントの表示検証 → Unit (React Testing Library)

## AI 機能の評価方針

AI 機能は通常のユニットテストとは異なり、厳密な文字列一致は使わない。

### 評価観点

- **構造評価**: レスポンスが期待するフォーマット（JSON schema 等）に準拠しているか
- **失敗時動作**: LLM がエラーを返した場合に適切なフォールバックが行われるか
- **引用**: RAG を使う場合、ソース情報が適切に引用されているか
- **再試行**: 一時的なエラー時のリトライロジックが機能するか
- **境界条件**: 空入力、長大入力、悪意ある入力に対して安全に処理されるか
- **コスト**: トークン使用量が想定範囲内か

### 評価データ

- 評価用のゴールデンデータセットを用意する
- 人手評価のガイドラインを定義する
- LLM-as-Judge パターンを検討する

## PentAGI の位置づけ

PentAGI は security-reviewer が使うセキュリティ検証ツールである。

### 絶対ルール

- **本番環境に対して絶対に実行しない**
- ステージングまたは隔離環境に限定する
- 結果は必ず人間が再確認する
- 誤検知を前提として扱う

### 検証対象

- API エンドポイントの認証・認可
- 入力バリデーション
- ファイルアップロード
- セッション管理
- CORS 設定
- LLM 特有の攻撃面（プロンプトインジェクション、出力漏洩）

### 結果分類

- Critical: 即座に修正が必要
- High: リリース前に修正が必要
- Medium: 次スプリントで対応
- Low: バックログに積む

## Docker 開発の原則

- ローカル開発は Docker Compose を第一選択とする
- `make up` で全サービスが起動する状態を維持する
- DB マイグレーション・シードは Docker 経由で実行する
- ボリュームを使ってソースコードのホットリロードを実現する
- 本番用 Dockerfile と開発用 Dockerfile.dev は分離する

## AWS 固有の注意点

- AWS 関連の設計・操作は aws-platform-engineer に閉じる
- common skill に AWS 固有の処理を書かない
- シークレットは Secrets Manager で管理し、ハードコードしない
- デプロイはコンテナイメージベースで統一する
- IAM ロールは最小権限の原則に従う

## PR 時の確認観点

PR レビュー時に以下を確認する:

1. **テスト**: 新機能に対するテストが追加されているか
2. **TDD**: テストが実装より先に書かれたか（コミット履歴で確認）
3. **型安全**: TypeScript の型が適切に定義されているか
4. **セキュリティ**: 入力バリデーション、認証、認可が適切か
5. **AI 品質**: AI 機能の場合、構造評価と失敗時動作が検証されているか
6. **Docker 互換**: Docker 環境で動作するか
7. **ドキュメント**: 必要なドキュメントが更新されているか

## 実装時の禁止事項

- `any` 型の使用（`unknown` を使い、型ガードで絞り込む）
- `console.log` のコミット（ロガーを使用する）
- 環境変数のハードコード（`.env` と Secrets Manager を使用する）
- テストなしのマージ
- try-catch の空ブロック（エラーを適切に処理する）
- `// TODO` の放置（Issue を作成する）
- PentAGI の本番環境での実行
- Agent の管轄を超えた操作
- Skill の中で判断ロジックを持つこと（判断は Agent の責務）

## Claude に依頼する際のルール

- まず product-manager に要件を伝える
- Agent / Skill の使い分けに従う
- 実装前に tdd-coach で受け入れ条件を定義する
- セキュリティに影響する変更は security-reviewer を通す
- AWS 変更は aws-platform-engineer に依頼する
- 1 つの PR で複数の機能を混ぜない

## 既存設計を壊さないための原則

- 新機能は既存モジュールの変更を最小限にする
- 既存テストが全て通ることを確認してからマージする
- 共通パッケージの変更は全依存先に影響がないか確認する
- DB スキーマ変更は破壊的変更を避け、マイグレーションで管理する
- 環境変数の追加は `.env.example` も同時に更新する
- Agent / Skill の責務境界を変更する場合は solution-architect に確認する

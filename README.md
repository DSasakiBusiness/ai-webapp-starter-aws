# AI Webapp Starter AWS

**AI 特化 Web サービスを最速で立ち上げるための、本格スターターリポジトリ。**

Claude Code のエージェント・スキル定義を内蔵し、TDD × Docker × AWS の開発フローがすぐに動き出します。

---

## ✨ このスターターで何ができるか

| できること                     | 詳細                                                                                                             |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| 🤖 **AI/LLM 統合開発**         | OpenAI / Anthropic を Provider パターンで交換可能に統合。RAG、ストリーミング、品質評価パイプラインの設計指針付き |
| 🐳 **Docker ワンコマンド起動** | `make up` だけで PostgreSQL + NestJS API + Next.js フロントが起動                                                |
| 🧪 **TDD 即実践**              | Jest (API/Web) + Playwright (E2E) が設定済み。テストファイルのサンプルも同梱                                     |
| 🤝 **Claude Code 連携**        | 10 エージェント × 28 スキルの定義済み。Claude Code がタスクに応じて適切な手順を自動参照                          |
| ☁️ **AWS デプロイ対応**        | App Runner / ECS、RDS、ECR 向けの CI/CD パイプラインと CloudFormation テンプレート                               |
| 🔒 **セキュリティ組み込み**    | PentAGI スキャン、OWASP 対策、プロンプトインジェクション防御のガイドライン                                       |
| 📏 **コード品質自動管理**      | pre-commit フック、Conventional Commits、スペルチェック、未使用コード検出を自動化                                |
| 📦 **モノレポ構成**            | Turborepo + npm workspaces で API / Web / 共通パッケージを統合管理                                               |

---

## 🚀 クイックスタート

```bash
# 1. クローン
git clone https://github.com/DSasakiBusiness/ai-webapp-starter-aws.git
cd ai-webapp-starter-aws

# 2. セットアップ（.env コピー、依存インストール、Prisma Client 生成）
make setup

# 3. .env を編集して LLM API キーを設定（任意）
#    OPENAI_API_KEY=sk-...
#    ANTHROPIC_API_KEY=sk-ant-...

# 4. Docker で起動
make up

# 5. DB マイグレーション & シード
make db-migrate
make db-seed
```

| サービス      | URL                                      |
| ------------- | ---------------------------------------- |
| Web (Next.js) | http://localhost:3000                    |
| API (NestJS)  | http://localhost:3001/api/v1/health      |
| Prisma Studio | `make db-studio` → http://localhost:5555 |

---

## 🛠 技術スタック

### アプリケーション

| レイヤー     | 技術                                   | 備考                                     |
| ------------ | -------------------------------------- | ---------------------------------------- |
| Frontend     | **Next.js 15** (App Router) + React 19 | TypeScript、SSR/SSG 対応                 |
| Backend      | **NestJS 10** + Prisma ORM             | DI、Guard、Filter、Interceptor パターン  |
| Database     | **PostgreSQL 16**                      | Docker で自動起動、Healthcheck 付き      |
| 共通型定義   | `packages/shared`                      | API レスポンス型、チャットメッセージ型等 |
| モノレポ管理 | **Turborepo** + npm workspaces         | ビルド・テスト・lint のキャッシュ最適化  |

### AI / LLM

| 項目             | 内容                                                            |
| ---------------- | --------------------------------------------------------------- |
| 対応プロバイダー | OpenAI、Anthropic（Provider パターンで追加可能）                |
| 設計パターン     | [8 つの厳選 Agentic パターン](docs/ai-patterns/README.md)を適用 |
| ストリーミング   | Server-Sent Events (SSE)                                        |
| RAG              | Retrieval → Augmentation → Generation の 3 段階設計             |
| 品質評価         | Self-Critique Loop + Structured Output (Zod)                    |
| セキュリティ     | Hook-Based Safety Guard Rails（入出力フック）                   |
| コスト管理       | Budget-Aware Model Routing + LLM Observability                  |

### インフラ / CI/CD

| 項目                 | 内容                                            |
| -------------------- | ----------------------------------------------- |
| ローカル開発         | **Docker Compose**（PostgreSQL + API + Web）    |
| CI                   | **GitHub Actions** — lint / test / build / E2E  |
| セキュリティスキャン | Trivy (Docker)、TruffleHog (secrets)、npm audit |
| デプロイ             | **AWS** — App Runner or ECS/Fargate + RDS + ECR |
| IaC                  | CloudFormation テンプレート                     |

---

## 📏 コード品質ツール

コミット時に自動実行されるものと、手動で実行するものが揃っています。

### 自動実行（Git フック）

| ツール                      | タイミング   | 動作                                                  |
| --------------------------- | ------------ | ----------------------------------------------------- |
| **husky** + **lint-staged** | `pre-commit` | ステージされたファイルに Prettier + cspell を自動実行 |
| **commitlint**              | `commit-msg` | `feat:` `fix:` 等の Conventional Commits を強制       |

### 手動実行

| ツール                | コマンド           | 用途                               |
| --------------------- | ------------------ | ---------------------------------- |
| **cspell**            | `make spell`       | コード内スペルチェック             |
| **knip**              | `make knip`        | 未使用ファイル・export・依存の検出 |
| **madge**             | `make circular`    | 循環 import の検出                 |
| **depcheck**          | `make deps-check`  | 未使用 dependencies の検出         |
| **ncu**               | `make deps-update` | 依存パッケージの更新チェック       |
| **sort-package-json** | `make sort-pkg`    | package.json のキーソート          |
| **Prettier**          | `make format`      | コードフォーマット                 |

### 一括実行

```bash
make quality  # lint + format-check + spell + knip + circular を一括実行
```

---

## 🧪 テスト

| 種類               | ツール                       | コマンド                | 実行環境  |
| ------------------ | ---------------------------- | ----------------------- | --------- |
| API ユニットテスト | Jest                         | `make test-unit`        | Docker 内 |
| Web ユニットテスト | Jest + React Testing Library | `make test-unit`        | Docker 内 |
| 統合テスト         | Jest + Prisma                | `make test-integration` | Docker 内 |
| E2E テスト         | Playwright                   | `make test-e2e`         | ホスト    |
| カバレッジ         | Jest --coverage              | `make test-cov`         | Docker 内 |

サンプルテスト付き:

- `apps/api/src/health/health.controller.spec.ts` — DB 接続の成功/失敗テスト
- `apps/web/src/app/page.test.tsx` — ページレンダリングテスト

---

## 🤝 Claude Code 連携

このリポジトリは Claude Code 用の `.claude/` 構成を正本として持っています。

### CLAUDE.md

プロジェクト横断ルール（TDD 必須、Docker 開発、console.log 禁止、セキュリティ等）。

### エージェント（10 種）

| カテゴリ        | エージェント          | 責務                             |
| --------------- | --------------------- | -------------------------------- |
| **Product**     | product-manager       | 要件定義、MVP 策定、受け入れ基準 |
| **Engineering** | solution-architect    | アーキテクチャ設計、技術選定     |
|                 | frontend-developer    | Next.js UI 実装                  |
|                 | backend-developer     | NestJS API 実装、Prisma スキーマ |
|                 | ai-engineer           | LLM 統合、RAG、AI 品質評価       |
| **Testing**     | tdd-coach             | TDD サイクル指導、テスト方針     |
|                 | qa-reviewer           | コード品質レビュー               |
|                 | e2e-tester            | Playwright E2E シナリオ          |
|                 | security-reviewer     | セキュリティ監査、脆弱性チェック |
| **AWS**         | aws-platform-engineer | AWS インフラ構築・運用           |

### スキル（28 種）

<details>
<summary>共通スキル（23 種）</summary>

| スキル                         | 用途                             |
| ------------------------------ | -------------------------------- |
| `tdd-feature-delivery`         | TDD サイクルでの機能実装         |
| `implement-nestjs-api`         | NestJS API エンドポイント実装    |
| `implement-nextjs-ui`          | Next.js UI コンポーネント実装    |
| `implement-prisma-schema`      | Prisma スキーマ設計              |
| `integrate-llm-feature`        | LLM 機能の統合                   |
| `build-rag-pipeline`           | RAG パイプライン構築             |
| `run-ai-evals`                 | AI 出力の品質評価実行            |
| `review-ai-output-quality`     | AI 出力品質レビュー              |
| `write-api-contract`           | API 契約（スキーマ）定義         |
| `generate-ui-spec`             | UI 仕様書生成                    |
| `setup-docker-dev-environment` | Docker 開発環境セットアップ      |
| `manage-prisma-in-docker`      | Docker 内での Prisma 操作        |
| `run-tests-in-docker`          | Docker 内でのテスト実行          |
| `e2e-readiness-pipeline`       | E2E テスト準備パイプライン       |
| `setup-pentagi-scan`           | PentAGI セキュリティスキャン設定 |
| `review-security-with-pentagi` | PentAGI でのセキュリティレビュー |
| `secure-release-pipeline`      | セキュアリリースパイプライン     |
| `review-performance`           | パフォーマンスレビュー           |
| `review-release-readiness`     | リリース準備確認                 |
| `clarify-product-requirements` | プロダクト要件の明確化           |
| `clarify-ai-requirements`      | AI 要件の明確化                  |
| `clarify-test-scope`           | テストスコープの明確化           |
| `define-mvp`                   | MVP 定義                         |

</details>

<details>
<summary>AWS スキル（5 種）</summary>

| スキル                    | 用途                       |
| ------------------------- | -------------------------- |
| `design-aws-architecture` | AWS アーキテクチャ設計     |
| `deploy-to-aws`           | AWS へのデプロイ実行       |
| `setup-aws-ci-cd`         | AWS CI/CD パイプライン構築 |
| `configure-aws-secrets`   | AWS Secrets Manager 設定   |
| `monitor-on-aws`          | AWS 監視設定               |

</details>

---

## 📁 ディレクトリ構成

```
ai-webapp-starter-aws/
├── .claude/                        # Claude Code 正本
│   ├── CLAUDE.md                   #   プロジェクト横断ルール
│   ├── agents/                     #   エージェント定義（10 種）
│   │   ├── product/                #     product-manager
│   │   ├── engineering/            #     solution-architect, frontend/backend-developer, ai-engineer
│   │   ├── testing/                #     qa-reviewer, tdd-coach, e2e-tester, security-reviewer
│   │   └── aws/                    #     aws-platform-engineer
│   └── skills/                     #   スキル手順書（28 種）
│       ├── common/                 #     共通スキル（23）
│       └── aws/                    #     AWS 固有スキル（5）
│
├── apps/
│   ├── api/                        # NestJS バックエンド
│   │   ├── src/
│   │   │   ├── common/             #   HttpExceptionFilter, LoggingInterceptor
│   │   │   ├── health/             #   ヘルスチェック（テスト付き）
│   │   │   └── prisma/             #   Prisma サービス
│   │   ├── prisma/                 #   スキーマ、マイグレーション、シード
│   │   ├── Dockerfile              #   本番用（マルチステージビルド）
│   │   └── Dockerfile.dev          #   開発用（ホットリロード対応）
│   └── web/                        # Next.js フロントエンド
│       ├── src/
│       │   ├── app/                #   App Router ページ（テスト付き）
│       │   └── lib/                #   型安全 API Client
│       ├── jest.config.ts          #   Jest 設定
│       ├── Dockerfile              #   本番用
│       └── Dockerfile.dev          #   開発用
│
├── packages/
│   └── shared/                     # 共通型定義
│       └── src/index.ts            #   ApiResponse, ChatMessage, TokenUsage 等
│
├── tests/
│   └── e2e/                        # Playwright E2E テスト
│       └── playwright.config.ts
│
├── docs/                           # ドキュメント
│   ├── ai-patterns/                #   AI エージェントパターン（8 種厳選）
│   ├── development-guide.md        #   開発ワークフロー・命名規約
│   ├── architecture.md             #   システム構成
│   ├── testing-strategy.md         #   テスティングピラミッド
│   ├── ai-integration.md           #   LLM 統合ガイド
│   ├── security.md                 #   セキュリティ方針
│   ├── docker-development.md       #   Docker 開発ガイド
│   └── aws-deployment.md           #   AWS デプロイガイド
│
├── infra/
│   └── aws/cloudformation/         # AWS CloudFormation テンプレート
│
├── scripts/
│   ├── setup.sh                    # 初回セットアップスクリプト
│   └── wait-for-it.sh              # TCP ポート待ちユーティリティ
│
├── .github/workflows/
│   ├── ci.yml                      # CI パイプライン（lint, test, build, E2E）
│   ├── deploy.yml                  # AWS デプロイパイプライン
│   └── security-scan.yml           # セキュリティスキャン
│
├── docker-compose.yml              # ローカル開発環境（PostgreSQL + API + Web）
├── Makefile                        # 開発ショートカット（30+ ターゲット）
├── .prettierrc                     # Prettier 設定
├── commitlint.config.mjs           # Conventional Commits 設定
├── cspell.json                     # スペルチェック辞書
├── knip.json                       # 未使用コード検出設定
├── tsconfig.base.json              # TypeScript 共通設定
└── turbo.json                      # Turborepo 設定
```

---

## 📋 全コマンド一覧

### Docker

| コマンド        | 説明                                                   |
| --------------- | ------------------------------------------------------ |
| `make setup`    | 初回セットアップ（.env、npm install、Prisma generate） |
| `make up`       | 全サービスをバックグラウンド起動                       |
| `make down`     | 全サービスを停止                                       |
| `make restart`  | 全サービスを再起動                                     |
| `make build`    | 全サービスをキャッシュなしビルド                       |
| `make logs`     | 全ログを表示                                           |
| `make logs-api` | API ログのみ表示                                       |
| `make logs-web` | Web ログのみ表示                                       |
| `make clean`    | コンテナ・ボリュームを完全削除                         |
| `make check`    | ヘルスチェック                                         |

### Database

| コマンド           | 説明                             |
| ------------------ | -------------------------------- |
| `make db-migrate`  | Prisma マイグレーション実行      |
| `make db-generate` | Prisma Client 生成               |
| `make db-seed`     | シードデータ投入                 |
| `make db-studio`   | Prisma Studio（GUI）起動         |
| `make db-reset`    | DB 全リセット + マイグレーション |

### Testing

| コマンド                | 説明                           |
| ----------------------- | ------------------------------ |
| `make test`             | 全テスト（unit + integration） |
| `make test-unit`        | ユニットテスト                 |
| `make test-integration` | 統合テスト                     |
| `make test-e2e`         | E2E テスト（Playwright）       |
| `make test-e2e-ui`      | E2E テスト（UI モード）        |
| `make test-cov`         | カバレッジ付きテスト           |

### Code Quality

| コマンド            | 説明                          |
| ------------------- | ----------------------------- |
| `make quality`      | **品質チェック一括実行**      |
| `make lint`         | ESLint 実行                   |
| `make format`       | Prettier フォーマット         |
| `make format-check` | フォーマットチェック（CI 用） |
| `make spell`        | スペルチェック                |
| `make knip`         | 未使用コード検出              |
| `make circular`     | 循環依存検出                  |
| `make deps-check`   | 未使用依存検出                |
| `make deps-update`  | 依存更新チェック              |
| `make sort-pkg`     | package.json ソート           |

### Shell / Production

| コマンド                 | 説明                         |
| ------------------------ | ---------------------------- |
| `make shell-api`         | API コンテナにシェル接続     |
| `make shell-web`         | Web コンテナにシェル接続     |
| `make shell-db`          | DB に psql で接続            |
| `make docker-build-prod` | 本番用 Docker イメージビルド |

---

## 📚 ドキュメント

| ドキュメント                              | 内容                                                                             |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| [開発ガイド](docs/development-guide.md)   | 開発ワークフロー、TDD サイクル、命名規約、トラブルシューティング                 |
| [AI パターン](docs/ai-patterns/README.md) | 厳選 8 パターン（Structured Output, Plan-then-Execute, Budget-Aware Routing 等） |
| [アーキテクチャ](docs/architecture.md)    | システム構成、レイヤー設計                                                       |
| [テスト戦略](docs/testing-strategy.md)    | テスティングピラミッド、TDD、AI テスト方針                                       |
| [AI 統合](docs/ai-integration.md)         | LLM Provider パターン、ストリーミング、RAG                                       |
| [Docker 開発](docs/docker-development.md) | Docker Compose の操作と Prisma 管理                                              |
| [セキュリティ](docs/security.md)          | PentAGI 運用、OWASP 対策、LLM セキュリティ                                       |
| [AWS デプロイ](docs/aws-deployment.md)    | App Runner / ECS、CloudFormation、CI/CD                                          |

---

## 🔧 環境変数

`.env.example` を `.env` にコピーして編集してください。主要な変数:

| 変数                | 用途                      | 例                                                     |
| ------------------- | ------------------------- | ------------------------------------------------------ |
| `DATABASE_URL`      | PostgreSQL 接続           | `postgresql://postgres:postgres@db:5432/ai_webapp_dev` |
| `JWT_SECRET`        | JWT 署名キー              | `your-secret-key`                                      |
| `OPENAI_API_KEY`    | OpenAI API キー           | `sk-...`                                               |
| `ANTHROPIC_API_KEY` | Anthropic API キー        | `sk-ant-...`                                           |
| `LLM_PROVIDER`      | 使用する LLM プロバイダー | `openai` or `anthropic`                                |
| `LLM_MODEL`         | 使用するモデル            | `gpt-4o`                                               |
| `LLM_MAX_TOKENS`    | 最大トークン数            | `4096`                                                 |
| `LLM_TEMPERATURE`   | Temperature               | `0.7`                                                  |

---

## ライセンス

MIT

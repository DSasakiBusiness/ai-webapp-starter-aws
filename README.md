# AI Webapp Starter AWS

AI 特化 Web サービス開発用のスターターリポジトリ（AWS デプロイ対応）。

Claude Code でそのまま活用できるよう設計されており、`.claude/` 配下にエージェント定義とスキル手順書を備えています。

## クイックスタート

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

起動後の確認先:

| サービス | URL |
|---|---|
| Web (Next.js) | http://localhost:3000 |
| API (NestJS) | http://localhost:3001/api/v1/health |
| Prisma Studio | `make db-studio` → http://localhost:5555 |

## 技術スタック

| レイヤー | 技術 |
|---|---|
| Frontend | Next.js 15 (App Router) + React 19 |
| Backend | NestJS 10 + Prisma ORM |
| Database | PostgreSQL 16 |
| AI/LLM | OpenAI / Anthropic（Provider パターンで交換可能） |
| Testing | Jest + React Testing Library + Playwright |
| CI/CD | GitHub Actions |
| Infrastructure | AWS (App Runner or ECS/Fargate) + RDS + ECR |
| Security | PentAGI（staging 限定） |
| Dev Environment | Docker Compose |

## ディレクトリ構成

```
ai-webapp-starter-aws/
├── .claude/                    # Claude Code 正本（エージェント・スキル定義）
│   ├── CLAUDE.md               #   プロジェクト横断ルール
│   ├── agents/                 #   エージェント定義（10 agents）
│   │   ├── product/            #     product-manager
│   │   ├── engineering/        #     solution-architect, frontend/backend-developer, ai-engineer
│   │   ├── testing/            #     qa-reviewer, tdd-coach, e2e-tester, security-reviewer
│   │   └── aws/                #     aws-platform-engineer
│   └── skills/                 #   スキル手順書（28 skills）
│       ├── common/             #     共通スキル（23）
│       └── aws/                #     AWS 固有スキル（5）
├── apps/
│   ├── api/                    # NestJS バックエンド
│   │   ├── src/
│   │   │   ├── common/         #   例外フィルター、インターセプター
│   │   │   ├── health/         #   ヘルスチェック（テスト付き）
│   │   │   └── prisma/         #   Prisma サービス
│   │   ├── prisma/             #   スキーマ、マイグレーション、シード
│   │   ├── Dockerfile          #   本番用（マルチステージ）
│   │   └── Dockerfile.dev      #   開発用（ホットリロード）
│   └── web/                    # Next.js フロントエンド
│       ├── src/
│       │   ├── app/            #   App Router ページ（テスト付き）
│       │   └── lib/            #   API Client
│       ├── Dockerfile          #   本番用（マルチステージ）
│       └── Dockerfile.dev      #   開発用（ホットリロード）
├── packages/
│   └── shared/                 # 共通型定義（ApiResponse, ChatMessage 等）
├── tests/
│   ├── unit/                   # ユニットテスト方針
│   ├── integration/            # 統合テスト方針
│   └── e2e/                    # E2E テスト（Playwright）
├── infra/
│   └── aws/cloudformation/     # AWS インフラテンプレート
├── scripts/                    # ユーティリティスクリプト
├── docs/                       # ドキュメント
├── .github/workflows/          # CI/CD ワークフロー
├── docker-compose.yml          # ローカル開発環境
└── Makefile                    # 開発ショートカット
```

## 主要コマンド

```bash
# Docker
make up              # サービス起動
make down            # サービス停止
make logs            # ログ表示
make check           # ヘルスチェック

# Database
make db-migrate      # マイグレーション
make db-seed         # シードデータ
make db-studio       # Prisma Studio（GUI）
make db-reset        # 全リセット

# Testing
make test-unit       # ユニットテスト
make test-integration # 統合テスト
make test-e2e        # E2E テスト
make test-cov        # カバレッジ

# Code Quality
make lint            # リント
make format          # フォーマット

# Shell
make shell-api       # API コンテナに接続
make shell-db        # DB に psql で接続

# Production
make docker-build-prod  # 本番イメージビルド
```

## Claude Code での活用

このリポジトリは Claude Code 用の `.claude/` 構成を持っています:

- **CLAUDE.md** — プロジェクト横断ルール（TDD、Docker、セキュリティ等）
- **agents/** — 10 種のエージェント定義（役割と責務）
- **skills/** — 28 種のスキル手順書（再利用可能な作業手順）

Claude Code 上で作業する場合、エージェントが状況に応じて適切なスキルを参照し、TDD サイクルに従って開発を進めます。

## ドキュメント

| ドキュメント | 内容 |
|---|---|
| [アーキテクチャ](docs/architecture.md) | システム構成、レイヤー設計 |
| [開発ガイド](docs/development-guide.md) | 開発ワークフロー、命名規約、トラブルシューティング |
| [Docker 開発](docs/docker-development.md) | Docker Compose の操作と Prisma 管理 |
| [テスト戦略](docs/testing-strategy.md) | テスティングピラミッド、TDD、AI テスト方針 |
| [AI 統合](docs/ai-integration.md) | LLM Provider パターン、ストリーミング、RAG |
| [セキュリティ](docs/security.md) | PentAGI 運用、OWASP 対策、LLM セキュリティ |
| [AWS デプロイ](docs/aws-deployment.md) | App Runner / ECS、CloudFormation、CI/CD |

## ライセンス

MIT

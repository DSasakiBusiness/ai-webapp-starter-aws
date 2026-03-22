# AI Webapp Starter AWS

AI 特化 Web サービス開発用スターターリポジトリ。  
Next.js + NestJS + Prisma + LLM + Docker + AWS の実務投入レベルのテンプレート。

## 想定ユースケース

- AI チャットアプリ
- RAG を活用したナレッジベース検索
- LLM を組み込んだ業務システム
- AI コンテンツ生成サービス
- ドキュメント解析・要約サービス

## 技術スタック

| レイヤー | 技術 |
|---|---|
| Frontend | Next.js (App Router) |
| Backend | NestJS |
| ORM | Prisma |
| Database | PostgreSQL |
| AI | OpenAI / Anthropic SDK |
| RAG | Embedding + Vector DB (オプション) |
| E2E Test | Playwright |
| CI/CD | GitHub Actions |
| Infrastructure | AWS (App Runner / ECS Fargate) |
| Local Dev | Docker / Docker Compose |

## ディレクトリ構成

```
ai-webapp-starter-aws/
├── .claude/                      # Claude Code 設定
│   ├── CLAUDE.md                 # プロジェクト横断ルール
│   ├── agents/                   # AI エージェント定義
│   │   ├── product/              #   プロダクト系
│   │   ├── engineering/          #   エンジニアリング系
│   │   ├── testing/              #   テスト・品質系
│   │   └── aws/                  #   AWS 専用
│   └── skills/                   # 再利用可能スキル
│       ├── common/               #   共通スキル (23)
│       └── aws/                  #   AWS 専用スキル (5)
├── apps/
│   ├── web/                      # Next.js フロントエンド
│   │   ├── Dockerfile            #   本番用
│   │   ├── Dockerfile.dev        #   開発用
│   │   └── src/                  #   ソースコード
│   └── api/                      # NestJS バックエンド
│       ├── Dockerfile            #   本番用
│       ├── Dockerfile.dev        #   開発用
│       ├── prisma/               #   Prisma スキーマ
│       └── src/                  #   ソースコード
├── packages/
│   └── shared/                   # 共通型・ユーティリティ
├── tests/
│   ├── unit/                     # ユニットテスト方針
│   ├── integration/              # 統合テスト方針
│   └── e2e/                      # E2E テスト (Playwright)
├── infra/
│   └── aws/                      # AWS インフラ定義
├── .github/
│   └── workflows/                # CI/CD パイプライン
├── docs/                         # ドキュメント
├── docker-compose.yml            # ローカル開発環境
├── Makefile                      # ショートカットコマンド
└── README.md
```

## Agents 一覧

| Agent | 役割 |
|---|---|
| product-manager | プロダクト要件の定義と優先度判断 |
| solution-architect | 全体設計・責務境界・非機能要件の設計 |
| frontend-developer | Next.js による UI 実装 |
| backend-developer | NestJS による API 実装 |
| ai-engineer | LLM / RAG 統合の設計・実装 |
| qa-reviewer | コード品質レビュー・品質基準の判定 |
| tdd-coach | TDD サイクルの監督・受け入れ条件の定義 |
| e2e-tester | Playwright による E2E テストの設計・実行 |
| security-reviewer | セキュリティレビュー・PentAGI による検証 |
| aws-platform-engineer | AWS 固有の設計・デプロイ・監視 |

## Skills 一覧

### Common Skills (23)

| Skill | 用途 |
|---|---|
| clarify-product-requirements | プロダクト要件の明確化 |
| define-mvp | MVP スコープの定義 |
| implement-nextjs-ui | Next.js UI 実装手順 |
| implement-nestjs-api | NestJS API 実装手順 |
| implement-prisma-schema | Prisma スキーマ変更手順 |
| integrate-llm-feature | LLM 機能統合手順 |
| build-rag-pipeline | RAG パイプライン構築手順 |
| tdd-feature-delivery | TDD による機能開発手順 |
| e2e-readiness-pipeline | E2E テスト準備手順 |
| review-security-with-pentagi | PentAGI セキュリティレビュー |
| run-ai-evals | AI 評価実行手順 |
| review-ai-output-quality | AI 出力品質レビュー |
| review-performance | パフォーマンスレビュー |
| write-api-contract | API 契約定義手順 |
| generate-ui-spec | UI 仕様生成手順 |
| secure-release-pipeline | セキュアリリース手順 |
| setup-pentagi-scan | PentAGI スキャン設定 |
| review-release-readiness | リリース準備レビュー |
| clarify-ai-requirements | AI 要件の明確化 |
| clarify-test-scope | テストスコープの明確化 |
| setup-docker-dev-environment | Docker 開発環境セットアップ |
| run-tests-in-docker | Docker でのテスト実行 |
| manage-prisma-in-docker | Docker での Prisma 操作 |

### AWS Skills (5)

| Skill | 用途 |
|---|---|
| design-aws-architecture | AWS アーキテクチャ設計 |
| deploy-to-aws | AWS デプロイ手順 |
| setup-aws-ci-cd | AWS CI/CD 設定 |
| configure-aws-secrets | AWS Secrets 管理 |
| monitor-on-aws | AWS 監視設定 |

## 初回セットアップ

### 前提条件

- Node.js >= 20.0.0
- npm >= 10.0.0
- Docker & Docker Compose
- Git

### 1. リポジトリのクローン

```bash
git clone https://github.com/your-org/ai-webapp-starter-aws.git
cd ai-webapp-starter-aws
```

### 2. 環境変数の設定

```bash
cp .env.example .env
# .env を編集して必要な値を設定
```

### 3. Docker を使ったセットアップ（推奨）

```bash
# 全サービスをビルド＆起動
make up

# ログを確認
make logs

# DB マイグレーション
make db-migrate

# シードデータ投入
make db-seed
```

### 4. ローカル直接セットアップ（Docker 不使用）

```bash
# 依存パッケージのインストール
npm install

# Prisma Client の生成
npm run db:generate

# DB マイグレーション（PostgreSQL が起動済みであること）
npm run db:migrate

# 開発サーバーの起動
npm run dev
```

## Docker を使った開発

### サービスの起動・停止

```bash
make up          # バックグラウンドで起動
make up-logs     # ログ表示付きで起動
make down        # 停止
make restart     # 再起動
make build       # 再ビルド
make clean       # 全削除（ボリュームも含む）
```

### ログの確認

```bash
make logs        # 全サービス
make logs-api    # API のみ
make logs-web    # Web のみ
make logs-db     # DB のみ
```

### シェルアクセス

```bash
make shell-api   # API コンテナ
make shell-web   # Web コンテナ
make shell-db    # DB コンテナ（psql）
```

## Prisma 操作

```bash
# Docker 経由
make db-migrate   # マイグレーション適用
make db-generate  # Client 生成
make db-seed      # シードデータ
make db-studio    # Prisma Studio
make db-reset     # DB リセット

# ローカル直接
npm run db:migrate
npm run db:generate
npm run db:seed
npm run db:studio
```

## テスト実行

```bash
# Docker 経由
make test             # 全テスト
make test-unit        # ユニットテスト
make test-integration # 統合テスト

# E2E テスト（ホストから実行）
make test-e2e         # ヘッドレス実行
make test-e2e-ui      # UI モード

# ローカル直接
npm run test
npm run test:unit
npm run test:integration
npm run test:e2e
```

## PentAGI セキュリティレビュー

> **⚠️ 重要: PentAGI は本番環境に対して絶対に実行しないでください。**

PentAGI はステージングまたは隔離環境でのみ使用します。

1. `.env` に PentAGI の接続情報を設定
2. ステージング環境をデプロイ
3. `security-reviewer` agent に PentAGI スキャンを依頼
4. 結果を Critical / High / Medium / Low で分類
5. 人間による再確認を必ず実施

詳細は [docs/security.md](docs/security.md) を参照。

## AWS デプロイ概要

### 推奨構成

- **コンピュート**: App Runner (シンプル) または ECS/Fargate (スケーラブル)
- **データベース**: RDS PostgreSQL
- **シークレット**: Secrets Manager
- **コンテナレジストリ**: ECR
- **CDN**: CloudFront
- **監視**: CloudWatch

### デプロイ手順

1. ECR にコンテナイメージをプッシュ
2. RDS PostgreSQL を構築
3. Secrets Manager にシークレットを登録
4. App Runner / ECS サービスを作成
5. CloudFront を構成（オプション）

詳細は [docs/aws-deployment.md](docs/aws-deployment.md) を参照。

## CI/CD 概要

GitHub Actions による自動化:

| ワークフロー | トリガー | 内容 |
|---|---|---|
| `ci.yml` | PR / push to main | lint, test, build |
| `deploy.yml` | push to main | ECR push, App Runner / ECS deploy |
| `security-scan.yml` | weekly / manual | 依存関係スキャン |

## 拡張方法

### 新しい API エンドポイントの追加

1. `tdd-coach` で受け入れ条件を定義
2. `write-api-contract` で API 契約を定義
3. `implement-nestjs-api` で実装
4. `tdd-feature-delivery` で TDD サイクル実行

### RAG 機能の追加

1. `clarify-ai-requirements` で要件を明確化
2. `build-rag-pipeline` でパイプラインを構築
3. `run-ai-evals` で評価を実行

### AWS サービスの追加

1. `design-aws-architecture` でアーキテクチャ設計
2. `deploy-to-aws` でデプロイ手順を定義
3. `configure-aws-secrets` でシークレット管理

## 注意点

- `.env` ファイルを Git にコミットしないこと
- LLM API キーは Secrets Manager で管理すること
- PentAGI は本番環境に対して絶対に実行しないこと
- Docker ボリュームを削除すると DB データが失われること
- 本番デプロイ前にセキュリティレビューを必ず実施すること

## ライセンス

MIT

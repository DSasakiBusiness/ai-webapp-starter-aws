# =============================================================================
# AI Webapp Starter AWS - Makefile
# =============================================================================
# Docker Compose を使ったローカル開発のショートカットコマンド集
# =============================================================================

.PHONY: help setup up down restart build logs clean \
        db-migrate db-generate db-seed db-studio db-reset \
        test test-unit test-integration test-e2e test-e2e-ui test-cov \
        lint format check \
        shell-api shell-web shell-db \
        docker-build-prod

# デフォルトターゲット
help: ## ヘルプを表示
	@echo ""
	@echo "AI Webapp Starter AWS - コマンド一覧"
	@echo "======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
setup: ## 初回セットアップ（.env コピー、npm install、Prisma generate）
	@bash scripts/setup.sh

# ---------------------------------------------------------------------------
# Docker Compose
# ---------------------------------------------------------------------------
up: ## 全サービスを起動（バックグラウンド）
	docker compose up -d
	@echo ""
	@echo "✅ サービス起動完了"
	@echo "   Web: http://localhost:$${WEB_PORT:-3000}"
	@echo "   API: http://localhost:$${API_PORT:-3001}/api/v1/health"
	@echo ""

up-logs: ## 全サービスを起動（ログ表示付き）
	docker compose up

down: ## 全サービスを停止
	docker compose down

restart: ## 全サービスを再起動
	docker compose restart

build: ## 全サービスをビルド（キャッシュなし）
	docker compose build --no-cache

logs: ## 全サービスのログを表示
	docker compose logs -f

logs-api: ## API サーバーのログを表示
	docker compose logs -f api

logs-web: ## Web サーバーのログを表示
	docker compose logs -f web

logs-db: ## データベースのログを表示
	docker compose logs -f db

clean: ## 全コンテナ・ボリュームを削除
	docker compose down -v --remove-orphans
	docker system prune -f

# ---------------------------------------------------------------------------
# Database (Prisma)
# ---------------------------------------------------------------------------
db-migrate: ## Prisma マイグレーションを実行
	docker compose exec api npx prisma migrate dev --schema=./apps/api/prisma/schema.prisma

db-generate: ## Prisma Client を生成
	docker compose exec api npx prisma generate --schema=./apps/api/prisma/schema.prisma

db-seed: ## シードデータを投入
	docker compose exec api npx prisma db seed

db-studio: ## Prisma Studio を起動（ブラウザで DB 操作）
	@echo "Prisma Studio: http://localhost:5555"
	docker compose exec api npx prisma studio --schema=./apps/api/prisma/schema.prisma

db-reset: ## DB をリセット（全データ削除 + マイグレーション + シード）
	docker compose exec api npx prisma migrate reset --schema=./apps/api/prisma/schema.prisma --force

# ---------------------------------------------------------------------------
# Testing
# ---------------------------------------------------------------------------
test: test-unit test-integration ## 全テストを実行（unit + integration）

test-unit: ## ユニットテストを実行
	docker compose exec api npm run test:unit
	docker compose exec web npm run test:unit

test-integration: ## 統合テストを実行
	docker compose exec api npm run test:integration

test-e2e: ## E2E テストを実行（Playwright）
	npx playwright test --config=tests/e2e/playwright.config.ts

test-e2e-ui: ## E2E テストを UI モードで実行
	npx playwright test --config=tests/e2e/playwright.config.ts --ui

test-cov: ## カバレッジ付きテストを実行
	docker compose exec api npm run test:cov

# ---------------------------------------------------------------------------
# Code Quality
# ---------------------------------------------------------------------------
lint: ## リントを実行
	npm run lint

format: ## コードフォーマットを実行
	npm run format

# ---------------------------------------------------------------------------
# Health Check
# ---------------------------------------------------------------------------
check: ## サービスのヘルスチェック
	@echo "--- Docker Compose Status ---"
	@docker compose ps
	@echo ""
	@echo "--- API Health ---"
	@curl -sf http://localhost:$${API_PORT:-3001}/api/v1/health 2>/dev/null && echo "" || echo "❌ API is not responding"
	@echo ""
	@echo "--- Web ---"
	@curl -sf -o /dev/null http://localhost:$${WEB_PORT:-3000} && echo "✅ Web is responding" || echo "❌ Web is not responding"

# ---------------------------------------------------------------------------
# Shell Access
# ---------------------------------------------------------------------------
shell-api: ## API コンテナにシェル接続
	docker compose exec api sh

shell-web: ## Web コンテナにシェル接続
	docker compose exec web sh

shell-db: ## DB コンテナにシェル接続（psql）
	docker compose exec db psql -U $${POSTGRES_USER:-postgres} -d $${POSTGRES_DB:-ai_webapp_dev}

# ---------------------------------------------------------------------------
# Production Build
# ---------------------------------------------------------------------------
docker-build-prod: ## 本番用 Docker イメージをビルド
	docker build -f apps/api/Dockerfile -t ai-webapp-api:latest .
	docker build -f apps/web/Dockerfile -t ai-webapp-web:latest .

#!/bin/sh
# =============================================================================
# setup.sh - 初回セットアップスクリプト
# =============================================================================
# Usage: ./scripts/setup.sh
#
# 初めてこのリポジトリをクローンしたときに実行する。
# 1. .env ファイルのコピー
# 2. npm install
# 3. Prisma Client の生成
# =============================================================================

set -e

echo "=========================================="
echo " AI Webapp Starter AWS - 初回セットアップ"
echo "=========================================="
echo ""

# .env ファイルのコピー
if [ ! -f .env ]; then
  echo "📄 .env.example → .env をコピーしています..."
  cp .env.example .env
  echo "   ✅ .env を作成しました。必要に応じて API キーを設定してください。"
else
  echo "📄 .env は既に存在します。スキップします。"
fi
echo ""

# npm install
echo "📦 依存パッケージをインストールしています..."
npm ci
echo "   ✅ npm ci 完了"
echo ""

# Prisma Client 生成
echo "🔧 Prisma Client を生成しています..."
npx prisma generate --schema=apps/api/prisma/schema.prisma
echo "   ✅ Prisma Client 生成完了"
echo ""

echo "=========================================="
echo " セットアップ完了！"
echo ""
echo " 次のステップ:"
echo "   1. .env を編集して API キーを設定"
echo "   2. make up        → Docker サービス起動"
echo "   3. make db-migrate → DB マイグレーション"
echo "   4. make db-seed    → シードデータ投入"
echo ""
echo " 確認:"
echo "   Web: http://localhost:3000"
echo "   API: http://localhost:3001/api/v1/health"
echo "=========================================="

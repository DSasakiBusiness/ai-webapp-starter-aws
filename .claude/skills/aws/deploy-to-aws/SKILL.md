---
name: deploy-to-aws
description: コンテナイメージを ECR にプッシュし、App Runner / ECS にデプロイする手順
---

# Deploy to AWS

## この skill を使う場面

- 初回デプロイ時
- 本番 / ステージングへの更新デプロイ時

## 入力前提

- AWS CLI が設定済み（`aws configure`）
- ECR リポジトリが作成済み
- RDS PostgreSQL が起動済み
- Secrets Manager にシークレットが設定済み

## 実行手順

### Step 1: ECR へのイメージプッシュ

```bash
# ECR ログイン
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com

# API イメージビルド＆プッシュ
docker build -f apps/api/Dockerfile -t ai-webapp-api:latest .
docker tag ai-webapp-api:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/ai-webapp-api:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/ai-webapp-api:latest

# Web イメージビルド＆プッシュ
docker build -f apps/web/Dockerfile -t ai-webapp-web:latest .
docker tag ai-webapp-web:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/ai-webapp-web:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/ai-webapp-web:latest
```

### Step 2: DB マイグレーション

ステージング / 本番 DB に対してマイグレーションを実行する:

```bash
# Bastion ホスト経由、または CI/CD タスクとして実行
DATABASE_URL="postgresql://..." npx prisma migrate deploy --schema=apps/api/prisma/schema.prisma
```

### Step 3: App Runner デプロイ（簡易構成の場合）

```bash
# App Runner サービスの作成 / 更新
aws apprunner create-service --cli-input-json file://infra/aws/apprunner-api.json
aws apprunner create-service --cli-input-json file://infra/aws/apprunner-web.json

# 更新時
aws apprunner start-deployment --service-arn ${SERVICE_ARN}
```

### Step 4: ECS/Fargate デプロイ（スケーラブル構成の場合）

```bash
# タスク定義の更新
aws ecs register-task-definition --cli-input-json file://infra/aws/task-definition.json

# サービスの更新（ローリングデプロイ）
aws ecs update-service --cluster ai-webapp --service api --task-definition ai-webapp-api:latest
aws ecs update-service --cluster ai-webapp --service web --task-definition ai-webapp-web:latest
```

### Step 5: デプロイ確認

```bash
# ヘルスチェック
curl https://api.example.com/api/v1/health

# CloudWatch Logs でエラーがないか確認
aws logs tail /ecs/ai-webapp-api --follow
```

## 判断ルール

- 初回デプロイ → CloudFormation / CDK でインフラを先に構築
- 更新デプロイ → イメージプッシュ + サービス更新
- ロールバック → 前バージョンのイメージを再デプロイ

## 出力形式

デプロイ結果（サービス URL、ステータス、ログ）。

## 注意点

- 本番デプロイ前にステージングでの確認を必須とする
- Blue/Green デプロイまたはローリングデプロイを使用する
- マイグレーションは後方互換性を保つ

## 失敗時の扱い

- デプロイ失敗: CloudWatch Logs でエラーを特定し、前バージョンにロールバック
- ヘルスチェック失敗: コンテナの起動ログを確認し、環境変数の設定を確認
- 接続エラー: セキュリティグループ、VPC の設定を確認

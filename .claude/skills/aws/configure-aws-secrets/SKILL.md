---
name: configure-aws-secrets
description: AWS Secrets Manager でシークレットを安全に管理する手順
---

# Configure AWS Secrets

## この skill を使う場面

- アプリケーションのシークレットを AWS に登録する場合
- シークレットのローテーションを設定する場合

## 入力前提

- AWS CLI が設定済み
- Secrets Manager へのアクセス権限がある IAM ロール

## 実行手順

### Step 1: シークレット作成

```bash
aws secretsmanager create-secret \
  --name ai-webapp/production \
  --description "AI Webapp production secrets" \
  --secret-string '{
    "DATABASE_URL": "postgresql://user:password@host:5432/dbname",
    "JWT_SECRET": "your-production-jwt-secret",
    "OPENAI_API_KEY": "sk-...",
    "ANTHROPIC_API_KEY": "sk-ant-..."
  }'
```

### Step 2: ステージング用シークレット

```bash
aws secretsmanager create-secret \
  --name ai-webapp/staging \
  --description "AI Webapp staging secrets" \
  --secret-string '{...}'
```

### Step 3: アプリケーションからの取得

NestJS のConfig Module で Secrets Manager から取得するか、ECS タスク定義で環境変数として注入する。

### Step 4: IAM ポリシー設定

アプリケーションの IAM ロールに Secrets Manager の読み取り権限を付与:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["secretsmanager:GetSecretValue"],
    "Resource": "arn:aws:secretsmanager:ap-northeast-1:*:secret:ai-webapp/*"
  }]
}
```

### Step 5: ローテーション設定（オプション）

DB パスワードの自動ローテーションを設定する。

## 判断ルール

- 全シークレットは Secrets Manager で管理（ハードコード禁止）
- 環境ごとにシークレットを分離する（production / staging）
- アクセスログを有効にする

## 出力形式

Secrets Manager の設定コマンド、IAM ポリシー。

## 注意点

- シークレット名の命名規則: `{app-name}/{environment}`
- コスト: シークレット 1 つあたり月額 $0.40
- シークレットの値は Git にコミットしない

## 失敗時の扱い

- 権限エラー: IAM ポリシーのリソース ARN を確認
- シークレット取得失敗: リージョンとシークレット名を確認

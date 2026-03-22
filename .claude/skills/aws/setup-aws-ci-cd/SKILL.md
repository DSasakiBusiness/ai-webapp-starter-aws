---
name: setup-aws-ci-cd
description: GitHub Actions から AWS への CI/CD パイプラインを設定する手順
---

# Setup AWS CI/CD

## この skill を使う場面

- CI/CD パイプラインを初めて設定する場合
- デプロイの自動化を構築する場合

## 入力前提

- GitHub リポジトリが設定済み
- AWS アカウントが利用可能
- OIDC プロバイダーが AWS に設定済み（推奨）

## 実行手順

### Step 1: OIDC 設定（GitHub Actions → AWS 認証）

IAM Identity Provider を作成し、GitHub Actions がAWS リソースにアクセスできるようにする:

```bash
# OIDC プロバイダーの作成
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### Step 2: IAM ロール作成

GitHub Actions 用の IAM ロールを最小権限で作成する（ECR プッシュ、ECS / App Runner デプロイ権限のみ）。

### Step 3: GitHub Secrets 設定

```
AWS_REGION: ap-northeast-1
AWS_ACCOUNT_ID: 123456789012
AWS_ROLE_ARN: arn:aws:iam::123456789012:role/github-actions-deploy
ECR_REPOSITORY_API: ai-webapp-api
ECR_REPOSITORY_WEB: ai-webapp-web
```

### Step 4: ワークフロー設定

`.github/workflows/deploy.yml` を設定:
- push to main → ビルド → テスト → ECR プッシュ → デプロイ

### Step 5: 動作確認

テスト PR を作成し、CI が正常に動作することを確認する。

## 判断ルール

- Secret キーは OIDC で管理（AWS_ACCESS_KEY_ID の直接設定は非推奨）
- ブランチ戦略: main → production, develop → staging
- デプロイ承認: 本番は手動承認ゲートを設定

## 出力形式

GitHub Actions ワークフローファイル、IAM ポリシー。

## 注意点

- AWS クレデンシャルを GitHub Secrets に直接保存しない（OIDC を使う）
- 本番デプロイは承認ゲートを設定する
- CI の実行時間を最適化する（キャッシュの活用）

## 失敗時の扱い

- OIDC 認証失敗: IAM ロールの信頼ポリシーを確認する
- ECR プッシュ失敗: IAM 権限と ECR リポジトリの存在を確認
- デプロイ失敗: CloudWatch Logs で原因を特定し、ロールバック

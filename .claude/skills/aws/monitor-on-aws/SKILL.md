---
name: monitor-on-aws
description: CloudWatch を使ったアプリケーション監視・アラート設定の手順
---

# Monitor on AWS

## この skill を使う場面

- アプリケーションの監視を設定する場合
- アラートを設定する場合
- パフォーマンス問題をデバッグする場合

## 入力前提

- AWS にアプリケーションがデプロイ済み
- CloudWatch へのアクセス権限

## 実行手順

### Step 1: ログ設定

- アプリケーションログを CloudWatch Logs に送信する
- ロググループ: `/ecs/ai-webapp-api`, `/ecs/ai-webapp-web`
- ログ保持期間: 30 日（本番）、7 日（ステージング）

### Step 2: メトリクス設定

監視するメトリクス:
- **インフラ**: CPU 使用率、メモリ使用率、ネットワーク I/O
- **アプリケーション**: リクエスト数、エラー率、レイテンシ（p50, p95, p99）
- **DB**: 接続数、クエリレイテンシ、ディスク使用量
- **AI**: LLM 応答時間、トークン使用量、エラー率

### Step 3: アラート設定

```bash
# エラー率アラート
aws cloudwatch put-metric-alarm \
  --alarm-name "ai-webapp-api-error-rate" \
  --metric-name "5xxErrors" \
  --namespace "AWS/AppRunner" \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:ap-northeast-1:${ACCOUNT_ID}:ai-webapp-alerts
```

### Step 4: ダッシュボード作成

CloudWatch ダッシュボードに主要メトリクスを集約する:
- API レイテンシ
- エラー率
- CPU/メモリ使用率
- DB 接続数

### Step 5: コスト監視

- AWS Budget を設定し、月額コスト上限でアラートを発報する
- Cost Explorer でサービスごとのコストを追跡する

## 判断ルール

- エラー率 > 1% → 調査開始
- レイテンシ p95 > 1s → パフォーマンス改善を検討
- CPU > 80% → スケーリング設定を確認
- コスト > 予算の 80% → リソース最適化を検討

## 出力形式

CloudWatch アラーム設定、ダッシュボード定義。

## 注意点

- アラートの閾値は段階的に調整する（初期は緩めに設定）
- On-Call ローテーションを設定する
- ログにPII を含めない

## 失敗時の扱い

- アラート疲れ: 閾値を見直し、ノイズを削減する
- ログが多すぎる: ログレベルの調整、サンプリングの導入

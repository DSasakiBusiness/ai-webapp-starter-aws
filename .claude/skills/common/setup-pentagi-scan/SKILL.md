---
name: setup-pentagi-scan
description: PentAGI のセットアップと隔離環境での構成手順
---

# Setup PentAGI Scan

## この skill を使う場面

- PentAGI を初めてプロジェクトに導入する場合
- PentAGI の設定を更新する場合

## 入力前提

- Docker が利用可能であること
- ステージング環境がデプロイ済みであること

## ⚠️ 安全上の絶対ルール

1. **本番環境に対して PentAGI を絶対に実行しない**
2. ステージングまたは完全に隔離された環境でのみ設定する
3. PentAGI コンテナは隔離された Docker ネットワークで実行する

## 実行手順

### Step 1: PentAGI 設定ファイル作成

PentAGI の設定ファイルを `infra/security/` に配置（本番環境とは完全に分離）。

### Step 2: Docker ネットワークの隔離

PentAGI 専用の Docker ネットワークを作成し、ステージング環境のみにアクセス可能にする。

### Step 3: スキャン対象の定義

```yaml
# infra/security/pentagi-targets.yml
targets:
  - name: api
    url: ${PENTAGI_TARGET_URL}
    auth:
      type: bearer
      token: ${PENTAGI_AUTH_TOKEN}
    scope:
      - /api/v1/*
    exclude:
      - /api/v1/health
```

### Step 4: 環境変数設定

`.env` に PentAGI 関連の環境変数を設定（コメントアウト状態で提供）。

### Step 5: 動作確認

ヘルスチェックエンドポイントに対して最小限のスキャンを実行し、PentAGI が正常に動作することを確認する。

## 判断ルール

- 初回セットアップ → 最小スコープでテストスキャンを実行
- 定期スキャン → 週次で自動実行（CI/CD に組み込み）

## 出力形式

PentAGI 設定ファイル、Docker Compose 拡張、自動化スクリプト。

## 注意点

- PentAGI のバージョンを固定する
- スキャンログは安全な場所に保存する
- 本番 URL が設定ファイルに絶対に含まれないようバリデーションする

## 失敗時の扱い

- PentAGI 起動失敗: Docker ログを確認、ポート競合を解消する
- ステージング接続失敗: ネットワーク設定とファイアウォールを確認する

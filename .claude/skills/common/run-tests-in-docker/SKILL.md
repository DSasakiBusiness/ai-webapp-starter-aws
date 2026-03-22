---
name: run-tests-in-docker
description: Docker 環境内でユニットテスト・統合テスト・E2E テストを実行する手順
---

# Run Tests in Docker

## この skill を使う場面

- Docker 環境でテストを実行する場合
- CI/CD パイプラインでのテスト実行手順を確認する場合

## 入力前提

- Docker Compose が起動済み（`make up`）
- DB マイグレーション済み（`make db-migrate`）

## 実行手順

### Step 1: ユニットテスト

```bash
# API のユニットテスト
docker compose exec api npm run test:unit

# Web のユニットテスト
docker compose exec web npm run test:unit

# 全ユニットテスト
make test-unit
```

### Step 2: 統合テスト

```bash
# API の統合テスト（DB を使用）
docker compose exec api npm run test:integration

# 全統合テスト
make test-integration
```

### Step 3: E2E テスト

E2E テストはホスト側の Playwright から Docker 内のサービスにアクセスして実行する:

```bash
# Docker サービスが起動していることを確認
make up

# ホスト側から E2E テスト実行
make test-e2e

# UI モードで実行（デバッグ用）
make test-e2e-ui
```

### Step 4: 全テスト実行

```bash
make test
```

## 判断ルール

- テスト失敗時 → ログを確認（`make logs-api`）して原因を特定
- DB 関連の失敗 → `make db-reset` でリセットしてから再実行
- E2E タイムアウト → サービスの起動完了を確認（ヘルスチェック）

## 出力形式

テスト実行結果（合格/不合格、カバレッジレポート）。

## 注意点

- 統合テスト用の DB は開発用 DB と共有しないことを推奨（テスト用スキーマを使う）
- E2E テストはサービスが完全に起動してから実行する
- テスト間でデータが干渉しないよう、各テストでクリーンアップする

## 失敗時の扱い

- コンテナが起動していない: `make up` で起動する
- DB 接続エラー: `make logs-db` でログを確認し、起動完了を待つ
- E2E テストが不安定: `make logs` で全サービスの状態を確認する

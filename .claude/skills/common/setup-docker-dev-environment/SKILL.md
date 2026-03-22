---
name: setup-docker-dev-environment
description: Docker Compose によるローカル開発環境のセットアップ手順
---

# Setup Docker Dev Environment

## この skill を使う場面

- プロジェクトに初めて参加するメンバーが環境構築する場合
- Docker 環境を再構築する場合
- 新しい依存サービスを追加する場合

## 入力前提

- Docker Desktop がインストール済み
- リポジトリがクローン済み

## 実行手順

### Step 1: 環境変数の設定

```bash
cp .env.example .env
# .env を編集（最低限 LLM API キーを設定）
```

### Step 2: Docker Compose でビルド＆起動

```bash
# 初回ビルド＆起動
make build
make up

# ログを確認して全サービスが正常起動したことを確認
make logs
```

### Step 3: DB の初期化

```bash
# マイグレーション実行
make db-migrate

# シードデータ投入
make db-seed
```

### Step 4: 動作確認

```bash
# Web: http://localhost:3000
# API: http://localhost:3001
# API ヘルスチェック
curl http://localhost:3001/api/v1/health
```

### Step 5: ホットリロードの確認

- `apps/web/src/` のファイルを編集 → ブラウザが自動リロード
- `apps/api/src/` のファイルを編集 → API が自動再起動

## 判断ルール

- ポート競合 → `.env` でポート番号を変更
- DB 接続エラー → `make logs-db` で PostgreSQL のログを確認
- node_modules の不整合 → `make clean` で全削除後、`make build` で再構築

## 出力形式

正常起動した Docker Compose 環境。

## 注意点

- Docker Desktop のメモリ割り当てを最低 4GB に設定する
- `make clean` はボリュームも削除するため、DB データが失われる
- ホスト側の node_modules と Docker 内の node_modules は別管理

## 失敗時の扱い

- ビルド失敗: Dockerfile のキャッシュが原因の可能性。`make build`（no-cache）で再ビルド
- ポート競合: `lsof -i :3000` で占有プロセスを特定し、停止する
- volumes 不整合: `docker compose down -v` で全ボリューム削除後、再起動

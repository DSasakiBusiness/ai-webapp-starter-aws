---
name: clarify-test-scope
description: テスト対象のスコープと種類を明確化する手順
---

# Clarify Test Scope

## この skill を使う場面

- 新機能のテスト方針を決める場合
- テストの過不足を確認する場合

## 入力前提

- product-manager の受け入れ条件
- 対象機能の技術的構成

## 実行手順

### Step 1: テスト対象の分析

機能を以下のレイヤーに分解:
- UI コンポーネント → Unit Test (React Testing Library)
- ビジネスロジック → Unit Test (Jest)
- API エンドポイント → Integration Test
- DB アクセス → Integration Test
- AI 機能 → AI Eval + Unit Test (構造評価)
- ユーザーフロー → E2E Test (Playwright)

### Step 2: テスト種類の割り当て

各受け入れ条件に対して最適なテスト種類を割り当てる。テスティングピラミッドに従い、Unit > Integration > E2E の比率を維持する。

### Step 3: テスト不要な範囲の明確化

テスト不要な範囲も明示する:
- フレームワーク自体の機能テスト
- 外部ライブラリの機能テスト
- 純粋な見た目のテスト（Visual Regression 以外）

### Step 4: tdd-coach に引き渡し

決定したテストスコープを tdd-coach に渡し、TDD サイクルを開始させる。

## 判断ルール

- ビジネスロジック → 必ず Unit Test
- DB アクセス → Integration Test 必須
- ユーザーの主要フロー → E2E Test 必須
- AI 出力 → 構造評価 + 失敗時動作テスト

## 出力形式

テストスコープドキュメント（テスト対象、種類、優先度のマトリクス）。

## 注意点

- テストの目的を明確にする（何を保証するためのテストか）
- 過剰テストも避ける（ROI を意識する）

## 失敗時の扱い

- スコープが決まらない: 最もリスクの高い部分から始める

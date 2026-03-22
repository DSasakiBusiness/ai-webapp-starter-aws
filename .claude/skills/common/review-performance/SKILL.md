---
name: review-performance
description: アプリケーションのパフォーマンスをレビューし改善提案を行う手順
---

# Review Performance

## この skill を使う場面

- ページロード時間が遅い場合
- API レスポンスが遅い場合
- リリース前のパフォーマンス確認

## 入力前提

- パフォーマンス要件（solution-architect が定義した目標値）
- テスト対象の環境

## 実行手順

### Step 1: フロントエンドパフォーマンス

1. Lighthouse スコアを計測（Performance, Accessibility, Best Practices, SEO）
2. Core Web Vitals を確認（LCP, FID, CLS）
3. バンドルサイズを分析（`next build` の出力）
4. 不要な Client Component を特定

### Step 2: バックエンドパフォーマンス

1. API レスポンスタイム（p50, p95, p99）を計測
2. N+1 クエリを検出（Prisma のログレベルを `query` に設定）
3. DB クエリの実行計画を確認（EXPLAIN ANALYZE）
4. メモリ使用量を確認

### Step 3: AI 機能パフォーマンス

1. LLM 応答時間（Time to First Token, Total Time）を計測
2. トークン使用量を確認
3. ストリーミングのチャンク送信間隔を確認

### Step 4: 改善提案

ボトルネックに対して具体的な改善提案を行う（キャッシュ追加、クエリ最適化、バンドル分割等）。

## 判断ルール

- LCP > 2.5s → 改善必須
- API p95 > 500ms → 最適化を検討
- バンドルサイズ > 500KB → コード分割を検討
- AI 応答 > 10s → ストリーミング必須

## 出力形式

パフォーマンスレポート（測定値、目標値、改善提案）。

## 注意点

- 計測は本番に近い環境（ステージング）で行う
- 複数回計測して平均値を使う

## 失敗時の扱い

- 計測環境が利用不可: ローカル Docker 環境での相対比較に切り替える

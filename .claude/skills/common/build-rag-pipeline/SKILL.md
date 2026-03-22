---
name: build-rag-pipeline
description: RAG (Retrieval-Augmented Generation) パイプラインを構築する手順
---

# Build RAG Pipeline

## この skill を使う場面

- 独自のナレッジベースに基づいた LLM 回答を実装する場合
- ドキュメント検索 + AI 回答生成を組み合わせる場合

## 入力前提

- clarify-ai-requirements の出力
- ナレッジソースの種類と量
- 検索精度の要件

## 実行手順

### Step 1: ドキュメント前処理

1. ソースドキュメントの収集（PDF, Markdown, Web ページ等）
2. テキスト抽出とクリーニング
3. チャンク分割（サイズ: 500-1000 トークン、オーバーラップ: 100-200 トークン）
4. メタデータ付与（ソース名、ページ番号、日時等）

### Step 2: Embedding 生成

```typescript
// modules/rag/services/embedding.service.ts
@Injectable()
export class EmbeddingService {
  async embed(text: string): Promise<number[]> {
    // OpenAI text-embedding-3-small を使用
    // バッチ処理で効率化
  }

  async embedBatch(texts: string[]): Promise<number[][]> {
    // 100 件ずつバッチ処理
  }
}
```

### Step 3: ベクトル DB 設定

Docker Compose にベクトル DB（Qdrant 等）を追加し、インデックスを作成する。

### Step 4: 検索パイプライン

```
ユーザークエリ → クエリ Embedding → ベクトル検索（Top-K）→ リランキング → コンテキスト組み立て → LLM 生成
```

### Step 5: 回答生成

検索結果をコンテキストとして LLM に渡し、回答を生成する。回答にはソース引用を含める。

### Step 6: 評価

- 検索精度: Recall@K, MRR
- 回答品質: 構造評価、引用正確性、幻覚検出

## 判断ルール

- ドキュメント量が 1000 件未満 → シンプルなベクトル検索で十分
- 検索精度不足 → ハイブリッド検索（ベクトル + キーワード）を検討
- レイテンシ要件が厳しい → キャッシュ、事前計算を検討
- ソースが頻繁に更新 → 差分インデックス更新パイプラインを構築

## 出力形式

- Embedding サービス、検索サービス、RAG サービスの TypeScript ファイル
- Docker Compose へのベクトル DB 追加
- テストファイル

## 注意点

- チャンクサイズは LLM のコンテキストウィンドウに収まるよう設計する
- 回答には必ずソース引用を含める
- 検索結果が 0 件の場合のフォールバックを実装する
- PII を含むドキュメントは前処理でマスキングする

## 失敗時の扱い

- 検索結果が 0 件: 「関連情報が見つかりませんでした」と返す
- Embedding API エラー: ローカルの Embedding モデルにフォールバック（オプション）
- ベクトル DB 接続エラー: キーワード検索にフォールバックする

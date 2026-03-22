# セキュリティガイド

## 原則

- 全通信を HTTPS で暗号化
- シークレットは Secrets Manager で管理（ハードコード禁止）
- IAM は最小権限の原則
- 入力は全てバリデーション
- テストなしのマージ禁止

## PentAGI セキュリティレビュー

### ⚠️ 絶対ルール

1. **本番環境に対して PentAGI を絶対に実行しない**
2. ステージングまたは隔離環境でのみ実行する
3. 結果は必ず人間が再確認する
4. 誤検知を前提として扱う

### 検証対象

- API 認証・認可
- 入力バリデーション（SQLi, XSS, SSRF）
- ファイルアップロード
- セッション管理（JWT）
- CORS 設定
- LLM 攻撃面（プロンプトインジェクション、出力漏洩）

### 結果分類

| 重大度 | 対応期限 |
|---|---|
| Critical | 即座に修正 |
| High | リリース前に修正 |
| Medium | 次スプリント |
| Low | バックログ |

## OWASP Top 10 対策

| リスク | 対策 |
|---|---|
| Injection | Prisma パラメータバインディング、入力バリデーション |
| Broken Auth | JWT + 有効期限 + リフレッシュトークン |
| Sensitive Data | HTTPS、Secrets Manager、PII マスキング |
| XXE | JSON のみ使用（XML 不使用） |
| Broken Access | NestJS Guard でロールベースアクセス制御 |
| Misconfiguration | Docker イメージスキャン（Trivy） |
| XSS | React の自動エスケープ、dangerouslySetInnerHTML 禁止 |
| Deserialization | class-validator + whitelist オプション |
| Components | npm audit + 週次スキャン |
| Logging | 構造化ログ + PII 除外 |

## LLM 固有のセキュリティ

- プロンプトインジェクション: システムプロンプトとユーザー入力の分離
- 出力漏洩: システムプロンプトの内容が漏れないよう出力をフィルタリング
- データ汚染: RAG ソースの品質管理
- コスト攻撃: トークン使用量の上限設定

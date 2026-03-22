/** @type {import('@commitlint/types').UserConfig} */
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // 型(type)は必須
    'type-enum': [
      2,
      'always',
      [
        'feat',     // 新機能
        'fix',      // バグ修正
        'docs',     // ドキュメント
        'style',    // フォーマット（コードの意味に影響しない変更）
        'refactor', // リファクタリング
        'perf',     // パフォーマンス改善
        'test',     // テスト追加・修正
        'build',    // ビルドシステム・外部依存の変更
        'ci',       // CI 設定の変更
        'chore',    // その他の変更
        'revert',   // コミットの取り消し
      ],
    ],
    // サブジェクトは空にしない
    'subject-empty': [2, 'never'],
    // 型は空にしない
    'type-empty': [2, 'never'],
    // サブジェクトの最大長
    'subject-max-length': [1, 'always', 100],
    // 日本語のコミットメッセージを許容するため、case ルールを無効化
    'subject-case': [0],
  },
};

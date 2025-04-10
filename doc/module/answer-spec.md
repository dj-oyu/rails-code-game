
# Answer モデル仕様

- id: integer
- problem_id: integer (references Problem)
- user_code: text
- result: string       # success, fail, timeout, error, syntax_error
- output: text         # 実行時の標準出力・エラー
- error_log: text      # エラー発生時の詳細ログ（JSON形式）
- created_at: datetime
- updated_at: datetime

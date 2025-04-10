
# Answer モデル仕様

- id: integer
- problem_id: integer (references Problem)
- user_code: text
- result: string       # success, fail, timeout, error
- output: text         # 実行時の標準出力・エラー
- created_at: datetime
- updated_at: datetime

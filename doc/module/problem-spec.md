
# Problem モデル仕様

- id: integer
- title: string
- description: text
- initial_code: text   # お題として提示する冗長コード
- test_code: text      # 提出コードを評価するRSpecコード（現在は未使用）
- expected_output: text # 期待する標準出力
- created_at: datetime
- updated_at: datetime

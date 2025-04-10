# 1行コード変換ゲーム - モジュール仕様

## 1. モジュール一覧

### コア機能
- **Problem**: お題管理
- **Answer**: 回答管理
- **CodeEvaluator**: コード評価
- **ProblemGenerator**: 問題自動生成

### UI
- **ProblemsController**: お題表示・管理
- **AnswersController**: 回答提出・評価

## 2. 各モジュールの責務

### Problem
- お題情報の保存・取得
- タイトル、説明文、初期コード、期待出力の管理

### Answer
- 提出された回答の保存・取得
- 評価結果、出力、エラーログの管理

### CodeEvaluator
- 提出コードの安全な実行
- 標準出力・戻り値の捕捉
- タイムアウト処理
- エラー種別の判定とログ生成

### ProblemGenerator
- LLM APIを使った問題自動生成
- 構造化出力の制御
- システムプロンプトの管理

### ProblemsController
- お題一覧・詳細の表示
- 問題自動生成の起動

### AnswersController
- 回答の受付
- 評価結果の表示

## 3. モジュール間の連携

```
[ブラウザ] <-> [ProblemsController] <-> [Problem]
                      |
                      v
[ブラウザ] <-> [AnswersController] <-> [Answer]
                      |                   ^
                      v                   |
                [CodeEvaluator] ----------+
                      
[ProblemsController] <-> [ProblemGenerator] <-> [Groq API]
```

## 4. データフロー

1. ユーザーがお題一覧を閲覧（`ProblemsController#index`）
2. ユーザーがお題詳細を閲覧（`ProblemsController#show`）
3. ユーザーが回答を提出（`AnswersController#create`）
4. 回答が`CodeEvaluator`で評価される
5. 評価結果が`Answer`に保存される
6. 評価結果がユーザーに表示される

## 5. 拡張ポイント

- **ユーザー認証**: 将来的にユーザーモデルを追加
- **Docker隔離**: `CodeEvaluator`を外部プロセスに置き換え
- **問題タグ付け**: `Problem`に`tags`カラムを追加

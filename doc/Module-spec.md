# 1行コード変換ゲーム - モジュール仕様

## 1. モジュール一覧

### コア機能
- **Problem**: お題管理
- **Answer**: 回答管理
- **CodeEvaluator**: コード評価
- **ProblemGenerator**: 問題自動生成
- **CodeParser**: コード解析

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
- **お題コードの実行時エラーを検出し、問題を破棄**
- **ユーザーコードが期待出力と一致する即値だけの場合はfail判定**
- **putsの引数や末尾の式に含まれる変数をnil/ランダム文字列で上書き**

### ProblemGenerator
- LLM APIを使った問題自動生成
- 構造化出力の制御
- システムプロンプトの管理
- 既存問題の例を提供

### CodeParser
- Rubyコードの静的解析
- 変数・メソッド・クラスの抽出
- 問題コードからシンボル情報の提供
- putsの引数に使われている変数はヒント一覧から除外
- 末尾の変数評価もヒント一覧から除外
- **putsの引数や末尾の式が複合式の場合、その中に含まれるすべての変数もヒント一覧から除外**
- putsの引数は`nil`で上書き
- 末尾の変数は**長いランダムな文字列**で上書き
- **ユーザーが期待出力と完全一致する即値（整数・文字列リテラル）をputsしただけの場合はfail判定**
- これにより、ユーザーがズルしてお題コードの答えをそのまま使うのを防止

### ProblemsController
- お題一覧・詳細の表示
- 問題自動生成の起動

### AnswersController
- 回答の受付
- 評価結果の表示

## 3. モジュール間の連携

```
[ブラウザ] <-> [ProblemsController] <-> [Problem]
                      |                   |
                      |                   v
                      |              [CodeParser]
                      v                   
[ブラウザ] <-> [AnswersController] <-> [Answer]
                      |                   ^
                      v                   |
                [CodeEvaluator] ----------+
                      
[ProblemsController] <-> [ProblemGenerator] <-> [Groq API]
                              ^
                              |
                        [CodeEvaluator] (問題検証)
```

## 4. データフロー

### 問題閲覧・回答フロー
1. ユーザーがお題一覧を閲覧（`ProblemsController#index`）
2. ユーザーがお題詳細を閲覧（`ProblemsController#show`）
   - `CodeParser`が問題コードから変数・メソッド情報を抽出
   - 抽出された情報がヒントとして表示される
3. ユーザーが回答を提出（`AnswersController#create`）
4. 回答が`CodeEvaluator`で評価される
   - 問題コードが先に評価され、変数・メソッドが環境に読み込まれる
   - ユーザーコードが評価され、出力と戻り値が捕捉される
5. 評価結果が`Answer`に保存される
6. 評価結果がユーザーに表示される

### 問題生成フロー
1. ユーザーが問題自動生成を要求（`ProblemsController#generate`）
2. `ProblemGenerator`がLLM APIを使って問題を生成
3. 生成された問題コードが`CodeEvaluator`で実行され、期待出力が計算される
4. シンタックスエラーがある場合は問題が破棄される
5. 問題が保存され、ユーザーに表示される

## 5. 拡張ポイント

- **ユーザー認証**: 将来的にユーザーモデルを追加
- **Docker隔離**: `CodeEvaluator`を外部プロセスに置き換え
- **問題タグ付け**: `Problem`に`tags`カラムを追加

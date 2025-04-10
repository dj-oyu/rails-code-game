doc
├── System-spec.md
├── Module-spec.md
├── module
│   ├── problem-spec.md
│   ├── answer-spec.md
│   └── ui-spec.md
└── overview.md

# Railsプロジェクト構成

app
├── controllers
│   ├── application_controller.rb
│   ├── problems_controller.rb
│   └── answers_controller.rb
├── models
│   ├── application_record.rb
│   ├── problem.rb
│   └── answer.rb
├── views
│   ├── layouts
│   ├── problems
│   │   ├── index.html.erb
│   │   └── show.html.erb
│   └── answers
│       └── create.html.erb
├── helpers
├── jobs
├── mailers
├── assets
│   ├── images
│   └── stylesheets

config
├── application.rb
├── boot.rb
├── environment.rb
├── environments
├── initializers
├── locales
├── puma.rb
├── routes.rb
├── database.yml

db
├── migrate
│   └── *.rb  # マイグレーションファイル
├── schema.rb
├── seeds.rb

lib
├── code_evaluator.rb
├── problem_generator.rb
├── code_parser.rb

spec
├── lib
│   ├── code_evaluator_spec.rb
│   └── problem_generator_spec.rb
├── rails_helper.rb
├── spec_helper.rb

.env
Gemfile
Rakefile
README.md

# 開発の振り返り

## 実装済み機能
- 問題一覧・詳細表示
- 回答提出と評価
- LLMによる問題自動生成
- 問題コードの実行による期待出力の自動計算
- 問題コード中の変数・メソッドをユーザーコード評価時に反映
- エラー表示の改善（簡潔なメッセージ、固定サイズ表示）
- 戻り値のフィードバック表示

## 反省点
1. **問題生成の品質管理**
   - 当初はLLMに期待出力も生成させていたが、不整合が発生
   - 問題コードを実行して期待出力を自動計算する方式に変更
   - シンタックスエラーのある問題は破棄するバリデーションを追加

2. **エラー表示の改善**
   - 初期実装ではサーバー側のディレクトリ構造が丸見えだった
   - エラーメッセージを簡潔にし、セキュリティリスクを軽減
   - 固定サイズのスクロール可能なコンテナでUXを改善

3. **変数・メソッドの名前空間**
   - 問題コード中の変数・メソッドをユーザーコードで使えるようにする必要があった
   - 問題コードを先に評価してから、ユーザーコードを評価する方式に変更

# 今後の計画

## 短期計画（次のスプリント）
1. **ユーザー認証の実装**
   - Deviseを使ったユーザー登録・ログイン機能
   - ユーザーごとの回答履歴管理

2. **問題タグ付け機能**
   - 問題にタグを付けて分類（配列操作、文字列処理など）
   - タグによる問題フィルタリング

3. **スコア・ランキング機能**
   - 回答の文字数や実行時間に基づくスコア計算
   - ユーザーランキングの表示

## 中期計画（3ヶ月以内）
1. **Docker隔離実行環境**
   - ユーザーコードを安全に実行するためのコンテナ化
   - セキュリティ強化とリソース制限

2. **問題投稿・共有機能**
   - ユーザーによる問題作成インターフェース
   - 問題の公開・非公開設定

3. **UI/UXの改善**
   - モバイル対応のレスポンシブデザイン
   - コードエディタの機能強化（シンタックスハイライト、自動補完）

## 長期計画（6ヶ月以上）
1. **学習分析機能**
   - ユーザーの弱点分析と推奨問題の提案
   - 学習進捗の可視化

2. **多言語対応**
   - Ruby以外の言語（Python、JavaScript等）への対応
   - 言語間の比較学習機能

3. **コミュニティ機能**
   - ユーザー間のコード共有・レビュー
   - 質問・回答フォーラム

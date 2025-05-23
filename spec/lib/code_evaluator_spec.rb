require "rails_helper"
require "code_evaluator"

RSpec.describe CodeEvaluator do
  let(:expected_output) { "15" }

  it "成功: 出力が一致すればsuccess" do
    user_code = "puts 10 + 5"
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end

  it "成功: 戻り値が一致すればsuccess" do
    user_code = "10 + 5"
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end

  it "問題コードに実行時エラーがあれば問題破棄" do
    # 実際にゼロ除算エラーが発生するコード
    initial_code = "1/0"

    # 文字列リテラルチェックを回避するため、
    # 期待出力と異なる文字列を出力するコードに変更
    user_code = "puts 'different_output'"

    # 期待出力も変更して文字列リテラルチェックを回避
    result = described_class.evaluate(user_code, "expected_but_different", initial_code: initial_code, timeout_sec: 2)

    # お題コードが実行時エラーを起こした場合は問題破棄
    expect(result[:result]).to eq("error")
    expect(result[:output]).to include("ZeroDivisionError")
    expect(result[:error_log]).to be_a(String)

    error_log = JSON.parse(result[:error_log])
    expect(error_log["error_type"]).to eq("problem_validation_error")
    expect(error_log["error_class"]).to eq("ZeroDivisionError")
    expect(error_log["initial_code"]).to eq(initial_code)
  end

  it "ユーザーが期待出力と同じ整数リテラルだけを返したらfail" do
    user_code = "15"
    result = described_class.evaluate(user_code, "15", timeout_sec: 2)
    expect(result[:result]).to eq("fail")
  end

  it "ユーザーが期待出力と同じ浮動小数点リテラルだけを返したらfail" do
    user_code = "1100.0"
    result = described_class.evaluate(user_code, "1100.0", timeout_sec: 2)
    expect(result[:result]).to eq("fail")
  end

  it "ユーザーが期待出力と同じ浮動小数点リテラルだけをputsしたらfail" do
    user_code = "puts 1100.0"
    result = described_class.evaluate(user_code, "1100.0", timeout_sec: 2)
    expect(result[:result]).to eq("fail")
  end

  it "ユーザーが期待出力と同じ整数リテラルだけをputsしたらfail" do
    user_code = "puts 15"
    result = described_class.evaluate(user_code, "15", timeout_sec: 2)
    expect(result[:result]).to eq("fail")
  end

  it "ユーザーが期待出力と同じ文字列リテラルだけを返したらfail" do
    user_code = '"15"'
    result = described_class.evaluate(user_code, "15", timeout_sec: 2)
    expect(result[:result]).to eq("fail")
  end

  it "ユーザーが期待出力と同じ文字列リテラルだけをputsしたらfail" do
    user_code = 'puts "15"'
    result = described_class.evaluate(user_code, "15", timeout_sec: 2)
    expect(result[:result]).to eq("fail")
  end

  it "ユーザーが計算式をputsしたらsuccess" do
    user_code = "puts 10 + 5"
    result = described_class.evaluate(user_code, "15", timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end

  it "ユーザーが計算式を返したらsuccess" do
    user_code = "10 + 5"
    result = described_class.evaluate(user_code, "15", timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end

  it "お題コードにputs無しで末尾に変数評価だけの場合、ユーザーがputsしても正解にならない" do
    initial_code = <<~RUBY
      x = 10
      y = 5
      expr = x + y
      # puts無し、末尾に変数評価だけ
      expr
    RUBY

    user_code = "puts expr"
    # お題コードはputsしないので期待出力は空文字
    result = described_class.evaluate(user_code, "", initial_code: initial_code, timeout_sec: 2)
    # exprはnilで上書きされているのでfailかerrorになるはず
    expect(result[:result]).to eq("fail").or eq("error")
    if result[:result] == "error"
      expect(result[:output]).to include("NameError").or include("nil")
    end
  end

  it "お題コードにputs無しで末尾に変数評価だけの場合、ユーザーが変数だけ返しても正解にならない" do
    initial_code = <<~RUBY
      x = 10
      y = 5
      expr = x + y
      # puts無し、末尾に変数評価だけ
      expr
    RUBY

    user_code = "expr"
    # お題コードはputsしないので期待出力は空文字
    result = described_class.evaluate(user_code, "", initial_code: initial_code, timeout_sec: 2)
    # exprはランダム文字列で上書きされているのでfailになるはず
    expect(result[:result]).to eq("fail")
  end

  it "お題コード末尾の変数評価はユーザーコードで使えない" do
    initial_code = <<~RUBY
      x = 10
      y = 5
      expr = x + y
      # 末尾に変数評価
      expr
    RUBY

    user_code = "puts expr"
    result = described_class.evaluate(user_code, "15", initial_code: initial_code, timeout_sec: 2)
    # exprはnilで上書きされているのでfailかerrorになるはず
    expect(result[:result]).to eq("fail").or eq("error")
    if result[:result] == "error"
      expect(result[:output]).to include("NameError").or include("nil")
    end
  end

  it "お題コード末尾の変数評価はユーザーコードで使えない（式のみ）" do
    initial_code = <<~RUBY
      x = 10
      y = 5
      expr = x + y
      # 末尾に変数評価
      expr
    RUBY

    user_code = "expr"
    result = described_class.evaluate(user_code, "15", initial_code: initial_code, timeout_sec: 2)
    # exprはランダム文字列で上書きされているのでfailになるはず
    expect(result[:result]).to eq("fail")
  end

  it "初期コードの変数が利用可能" do
    initial_code = "x = 10; y = 5"
    user_code = "puts x + y"
    result = described_class.evaluate(user_code, "15", initial_code: initial_code, timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end

  it "初期コードの変数が利用可能（式のみ）" do
    initial_code = "x = 10; y = 5"
    user_code = "x + y"
    result = described_class.evaluate(user_code, "15", initial_code: initial_code, timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end

  it "初期コードのメソッドが利用可能" do
    initial_code = "def add(a, b); a + b; end"
    user_code = "puts add(10, 5)"
    result = described_class.evaluate(user_code, "15", initial_code: initial_code, timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end

  it "初期コードのメソッドが利用可能（式のみ）" do
    initial_code = "def add(a, b); a + b; end"
    user_code = "add(10, 5)"
    result = described_class.evaluate(user_code, "15", initial_code: initial_code, timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end

  it "失敗: 出力が違えばfail" do
    user_code = "puts 42"
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
    expect(result[:result]).to eq("fail")
  end

  it "失敗: 戻り値が違えばfail" do
    user_code = "42"
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
    expect(result[:result]).to eq("fail")
  end

  it "タイムアウト: 無限ループならtimeout" do
    user_code = "loop {}"
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
    expect(result[:result]).to eq("timeout")
  end

  it "エラー: 例外発生ならerror" do
    user_code = "raise 'error'"
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
    expect(result[:result]).to eq("error")
  end

  it "構文エラー: シンタックスエラーならsyntax_error" do
    user_code = "def foo; end; }"  # 余分な閉じ括弧
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
    expect(result[:result]).to eq("syntax_error")
  end

  it "NoMethodError: メソッド未定義エラーならerror" do
    user_code = "(1..5).undefined_method"
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
    expect(result[:result]).to eq("error")
    expect(result[:output]).to include("NoMethodError")
    expect(result[:error_log]).to be_a(String)

    error_log = JSON.parse(result[:error_log])
    expect(error_log["error_type"]).to eq("runtime_error")
    expect(error_log["error_class"]).to eq("NoMethodError")
    expect(error_log["user_code"]).to eq(user_code)
  end

  it "NameError: 変数未定義エラーならerror" do
    user_code = "undefined_variable + 1"
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
    expect(result[:result]).to eq("error")
    expect(result[:output]).to include("NameError")
  end

  it "お題コードのputs引数の変数はユーザーコードで使えない" do
    initial_code = "result = 15; puts result"
    user_code = "puts result"
    result = described_class.evaluate(user_code, "15", initial_code: initial_code, timeout_sec: 2)
    # resultはnilで上書きされているので、出力は空 or nil.to_s
    expect(result[:result]).to eq("fail").or eq("error")
    # もしerrorならNameErrorのはず
    if result[:result] == "error"
      expect(result[:output]).to include("NameError").or include("nil")
    end
  end

  it "お題コードのputs引数の変数はユーザーコードで使えない（式のみ）" do
    initial_code = "result = 15; puts result"
    user_code = "result"
    result = described_class.evaluate(user_code, "15", initial_code: initial_code, timeout_sec: 2)
    # resultはnilで上書きされているのでfailになるはず
    expect(result[:result]).to eq("fail")
  end
end

require "rails_helper"
require "code_evaluator"

RSpec.describe CodeEvaluator do
  let(:expected_output) { "15" }

  it "成功: 出力が一致すればsuccess" do
    user_code = "puts 15"
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end
  
  it "初期コードの変数が利用可能" do
    initial_code = "x = 10; y = 5"
    user_code = "puts x + y"
    result = described_class.evaluate(user_code, "15", initial_code: initial_code, timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end
  
  it "初期コードのメソッドが利用可能" do
    initial_code = "def add(a, b); a + b; end"
    user_code = "puts add(10, 5)"
    result = described_class.evaluate(user_code, "15", initial_code: initial_code, timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end

  it "失敗: 出力が違えばfail" do
    user_code = "puts 42"
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
end

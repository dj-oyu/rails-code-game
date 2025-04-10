require "rails_helper"
require "code_evaluator"

RSpec.describe CodeEvaluator do
  let(:expected_output) { "15" }

  it "成功: 出力が一致すればsuccess" do
    user_code = "puts 15"
    result = described_class.evaluate(user_code, expected_output, timeout_sec: 2)
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
end

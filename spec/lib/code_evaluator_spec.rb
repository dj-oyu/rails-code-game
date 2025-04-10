require "rails_helper"
require "code_evaluator"

RSpec.describe CodeEvaluator do
  let(:test_code) do
    <<~RUBY
      describe 'sum' do
        it { expect(sum(1,2)).to eq(3) }
      end
    RUBY
  end

  it "正常系: 正しいコードならsuccessになる" do
    user_code = "def sum(a,b); a+b; end"
    result = described_class.evaluate(user_code, test_code, timeout_sec: 2)
    expect(result[:result]).to eq("success")
  end

  it "異常系: 無限ループならtimeoutになる" do
    user_code = "loop {}"
    result = described_class.evaluate(user_code, test_code, timeout_sec: 2)
    expect(result[:result]).to eq("timeout")
  end
end

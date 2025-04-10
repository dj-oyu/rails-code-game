require "rails_helper"
require "problem_generator"

RSpec.describe ProblemGenerator do
  it "LLMから問題を自動生成できる" do
    result = described_class.generate("テスト用の問題を作成してください")

    expect(result).to be_a(Hash)
    expect(result).to include("title", "description", "initial_code", "expected_output")
    expect(result["title"]).to be_a(String)
    expect(result["description"]).to be_a(String)
    expect(result["initial_code"]).to be_a(String)
    expect(result["expected_output"]).to be_a(String)
  end
end

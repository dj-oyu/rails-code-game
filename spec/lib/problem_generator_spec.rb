require "rails_helper"
require "problem_generator"

RSpec.describe ProblemGenerator do
  before do
    ENV["LLM_API_ENDPOINT"] = "http://localhost:8080/api"
    ENV["LLM_API_TOKEN"] = "dummy-token"
    ENV["LLM_MODEL"] = "dummy-model"
  end

  it "LLMから問題を自動生成できる" do
    mock_response = double("response")
    allow(mock_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

    response_content = {
      title: "Test Title",
      description: "Test Description",
      initial_code: "puts 'Hello, World!'",
      expected_output: ""
    }.to_json

    response_body = {
      choices: [
        {
          message: {
            content: response_content
          }
        }
      ]
    }.to_json

    allow(mock_response).to receive(:body).and_return(response_body)

    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)

    result = described_class.generate("テスト用の問題を作成してください")

    expect(result).to be_a(Hash)
    expect(result).to include("title", "description", "initial_code", "expected_output")
    expect(result["title"]).to eq("Test Title")
    expect(result["description"]).to eq("Test Description")
    expect(result["initial_code"]).to eq("puts 'Hello, World!'")
    expect(result["expected_output"]).to eq("")
  end
end

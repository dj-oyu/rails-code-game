require 'rails_helper'

RSpec.describe "Answers", type: :request do
  describe "POST /answers" do
    it "returns http success" do
      problem = Problem.create!(title: "Test", description: "Test problem", initial_code: "puts 'hello'", expected_output: "hello")
      post "/answers", params: { problem_id: problem.id, user_code: "puts 'test'" }, as: :json
      expect(response).to have_http_status(:success)
    end
  end
end

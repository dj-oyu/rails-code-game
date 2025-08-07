require 'rails_helper'

RSpec.describe "Answers", type: :request do
  describe "POST /create" do
    let!(:problem) { Problem.create!(title: "Test Problem", description: "Test Desc", initial_code: "puts 'hello'", expected_output: "hello\n") }

    it "returns http success" do
      post "/answers", params: { problem_id: problem.id, user_code: "puts 'hello'" }
      expect(response).to have_http_status(:success)
    end
  end
end

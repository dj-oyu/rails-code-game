require 'rails_helper'

RSpec.describe "Problems", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/problems"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    let!(:problem) { Problem.create!(title: "Test Problem", description: "Test Desc", initial_code: "puts 'hello'", expected_output: "hello\n") }

    it "returns http success" do
      get "/problems/#{problem.id}"
      expect(response).to have_http_status(:success)
    end
  end
end

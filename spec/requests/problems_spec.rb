require 'rails_helper'

RSpec.describe "Problems", type: :request do
  describe "GET /problems" do
    it "returns http success" do
      get "/problems"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /problems/:id" do
    it "returns http success" do
      problem = Problem.create!(title: "Test", description: "Test problem", expected_output: "test")
      get "/problems/#{problem.id}"
      expect(response).to have_http_status(:success)
    end
  end
end

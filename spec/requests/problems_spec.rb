require 'rails_helper'

RSpec.describe "Problems", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/problems/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/problems/show"
      expect(response).to have_http_status(:success)
    end
  end

end

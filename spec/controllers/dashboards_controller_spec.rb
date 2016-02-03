require 'rails_helper'

RSpec.describe DashboardsController, :type => :controller do
  describe "GET index" do
    before do
      sign_in
      get :index
    end

    it "should return to a http status success" do
      expect( response ).to have_http_status(:success)
    end
  end

  describe "GET stock" do
    before do
      sign_in
      get :stock
    end

    it "should return to a http status success" do
      expect( response ).to have_http_status(:success)
    end
  end
end

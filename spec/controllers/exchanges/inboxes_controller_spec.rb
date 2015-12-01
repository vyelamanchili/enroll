require 'rails_helper'

RSpec.describe Exchanges::InboxesController do
  context "GET show / DELETE destroy" do
    let(:user) { double("User") }
    let(:person) { double("Person") }
    let(:hbx_profile) { double("HbxProfile") }
    let(:message) { double("Message") }
    let(:inbox) { double("Inbox") }

    before do
      sign_in(user)
      allow(HbxProfile).to receive(:find).and_return(hbx_profile)
      allow(controller).to receive(:find_message)
      controller.instance_variable_set(:@message, message)
      allow(message).to receive(:update_attributes).and_return(true)
    end


    context "user with hbx staff role" do
      let(:user) { FactoryGirl.create(:user, person: person) }
      let(:person) { FactoryGirl.create(:person) }
      let(:inbox) { FactoryGirl.create(:inbox, recipient: hbx_profile) }
      let(:message){ FactoryGirl.create(:message, inbox: inbox) }
      let(:hbx_profile){ FactoryGirl.create(:hbx_profile) }



      before :each do
        sign_in(user)
        allow(user).to receive(:has_hbx_staff_role?).and_return(true)
      end

      it "show action" do
        get :show, id: 1
        expect(response).to have_http_status(:success)
      end

      it "delete action" do
        xhr :delete, :destroy, id: hbx_profile.id, message_id: message.id
        expect(response).to redirect_to(exchanges_hbx_profiles_path(hbx_profile.id, tab: "inbox", folder: "inbox"))
      end


    end

  end

end

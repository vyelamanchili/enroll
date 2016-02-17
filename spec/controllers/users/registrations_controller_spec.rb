require 'rails_helper'

RSpec.describe Users::RegistrationsController do

  context "create" do
    let(:curam_user){ double("CuramUser") }
    let(:email){ "test@example.com" }
    let(:password){ "aA1!aA1!aA1!"}

    context "when the email is in the black list" do

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        allow(CuramUser).to receive(:match_email).with(email).and_return([curam_user])
      end

      it "should redirect to saml recovery page if user matches" do
        post :create, { user: { email: email, password: password, password_confirmation: password } }
        expect(response).to be_success
        expect(flash[:alert]).to eq "An account with this email address ( #{email} ) already exists. <a href=\"#{SamlInformation.account_recovery_url}\">Click here</a> if you've forgotten your password."
      end

    end

    context "when the email is not the black list" do

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        allow(CuramUser).to receive(:match_email).with("test@example.com").and_return([])
      end

      it "should not redirect to saml recovery page if user matches" do
        post :create, { user: { email: "test@example.com", password: password, password_confirmation: password } }
        expect(response).not_to redirect_to(new_user_registration_path)
      end

    end

    context "account without person" do
      let(:email) { "devise@test.com" }

      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
      end

      subject do
        post :create, { user: { email: email, password: password, password_confirmation: password } }
      end

      it 'creates the user' do
        expect { subject }.to change { User.all.count }.by(1)
      end

      it "redirects to root_path" do
        subject
        expect(response).to redirect_to(root_path)
      end
    end

    context "account with person" do
      let(:email) { "devisepersoned@test.com"}
      let(:user) { FactoryGirl.create(:user, email: email, person: person) }
      let(:person) { FactoryGirl.create(:person) }

      before do
        user.save!
        @request.env["devise.mapping"] = Devise.mappings[:user]
      end

      it "should re-render the page" do
        post :create, { user: { email: email, password: password, password_confirmation: password } }
        expect(response).to be_success
        expect(response).not_to redirect_to(root_path)
      end
    end
  end
end

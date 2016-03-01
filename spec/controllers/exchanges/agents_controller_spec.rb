=begin
  User and person are tied together manually. This is not the correct way to do this. I dealing you would use
  ```
  create :user, :with_consumer_role
  ```
  This uses the enrollment factory to tie everything together.

  This spec is meant to be used to show a clean test and it should be refactored to use the enrollment factory as soon as possible.

  Enrollment factory was not used in this refactoring because the person_params method in spec/support/factories.rb doesn't seem to be generating unique data and ends up not creating a person because the person created from the first test still exists.
=end
require 'rails_helper'

module Exchanges
  describe AgentsController do
    let(:user) {create :user}
    let(:person) {create :person}

    context 'csr role' do
      before do
        # See notes above about fixing this before block.
        person.update(user_id: user.id.to_s)
        person.user.roles=['csr'] # why is a role defined here if its defined on the person?
      end

      describe 'cac: true ' do
        before do
          person.csr_role = FactoryGirl.build(:csr_role, cac: true) # why is a role defined here if its defined on the user?
          sign_in person.user
          session[:person_id] = person.id
          get :home
        end

        it 'sets @person' do
          expect(assigns[:person]).to eq person
        end

        it 'sets @title' do
          expect(assigns[:title]).to eq person.user.agent_title
        end
      end

      describe 'cac: false' do
        before do
          person.csr_role = FactoryGirl.build(:csr_role, cac: false)
          sign_in person.user
          session[:person_id] = person.id
          get :home
        end

        it 'sets @person' do
          expect(assigns[:person]).to eq person
        end

        it 'sets @title' do
          expect(assigns[:title]).to eq person.user.agent_title
        end
      end
    end

    context 'hbx_staff role' do
      before do
        person.update(user_id: user.id.to_s)
        person.user.roles=['hbx_staff']
        person.hbx_staff_role = FactoryGirl.build(:hbx_staff_role)
        sign_in person.user
        session[:person_id] = person.id
        get :home
      end

      it 'sets @person' do
        expect(assigns[:person]).to eq person
      end

      it 'sets @title' do
        expect(assigns[:title]).to eq person.user.agent_title
      end
    end

    context 'broker role' do
      before do
        person.update(user_id: user.id.to_s)
        person.user.roles=['broker']
        person.broker_role = FactoryGirl.build(:broker_role)
        sign_in person.user
        session[:person_id] = person.id
        get :home
      end

      it 'sets @person' do
        expect(assigns[:person]).to eq person
      end

      it 'sets @title' do
        expect(assigns[:title]).to eq person.user.agent_title
      end
    end

    context 'invalid role' do
      before do
        person.update(user_id: user.id.to_s)
        person.user.roles=['invalid']
        person.broker_role = FactoryGirl.build(:broker_role)
        sign_in person.user
        session[:person_id] = person.id
        get :home
      end

      it 'sets @person' do
        expect(response).to redirect_to root_path
      end

      it 'sets @title' do
        expect(flash[:error]).to_not be_nil
      end
    end

  end
end

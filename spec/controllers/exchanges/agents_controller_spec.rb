=begin
  User and person are tied together manually. This is not the correct way to do this. I dealing you would use
  ```
  create :user, :with_consumer_role
  ```
  This uses the enrollment factory to tie everything together.

  This spec is meant to be used to show a clean test and it should be refactored to use the enrollment factory as soon as possible.

  Enrollment factory was not initially used because there were issues with with object cacheing and it causing problems with recreating the setup after the first test was run.
=end
require 'rails_helper'

module Exchanges
  describe AgentsController do
    # render_views
    # Trait creates valid tie to a person
    let(:user) {create :user}
    let(:person) {create :person}


    # let(:person_user){Person.new(first_name: 'fred', last_name: 'flintstone')}
    # let(:current_user){FactoryGirl.create(:user)}
    # let(:signed_in?){ true }
    before do
      person.update(user_id: user.id.to_s)
      person.user.roles=['csr']
    end

    context 'Person csr_role cac: true ' do
      before do
        person.csr_role = FactoryGirl.build(:csr_role, cac: true)
        sign_in person.user
        session[:person_id] = person.id #unsure how this is being set in the controller
        get :home
      end

      it 'sets @person' do
        expect(assigns[:person]).to eq person
      end

      it 'sets @title' do # Initiating lazy loaded user does not create a person. Weird!
        expect(assigns[:title]).to eq person.user.agent_title
      end
    end

    context 'Person csr_role cac: false' do
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
end

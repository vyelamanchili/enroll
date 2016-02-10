require 'rails_helper'

describe FamiliesController do
  let(:user) {FactoryGirl.create :user, email: Faker::Internet.email}
  let(:family) {FactoryGirl.create :family, :with_primary_family_member, e_case_id: Faker::Number.number(10)}
  let(:family_member) { family.family_members.first }
  # let(:person) {FactoryGirl.create :person, :with_assister_role}
  
  before do
    family_member.person.update(user_id: user.id)
    sign_in(family_member.person.user)
  end
  
  describe 'GET index' do
    before {get :index}
    it 'sets @families' do
      expect(assigns[:families]).to eq family
    end
  end
end
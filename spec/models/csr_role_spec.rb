require 'rails_helper'

RSpec.describe CsrRole, dbclean: :after_each do
  let(:cac) {FactoryGirl.create(:csr_role, cac: true)}
  let(:person1) {FactoryGirl.create(:person)}
  let(:person2) {FactoryGirl.create(:person)}
  context 'cac_subrole' do
    describe '#ask_for_help' do
    	it 'should have one id if asked for help once' do
        cac.ask_for_help(person1.id.to_s)
        expect(cac.asked_for_help.count).to eq(1)
    	end
    	it 'should have two ids if asked for help by two unique persons' do
        cac.ask_for_help(person1.id.to_s)
        cac.ask_for_help(person2.id.to_s)
        cac.ask_for_help(person1.id.to_s)
        expect(cac.asked_for_help.count).to eq(2)
    	end
    end
    describe '#allowed_to_access' do
      it 'should return false if no asked_for_help ids' do
       expect(cac.allowed_to_access(person1.id.to_s)).to be_falsey
       expect(cac.allowed_to_access(person2.id.to_s)).to be_falsey
      end
      it 'should return false if asked_for_help array does not include person_id' do
       cac.ask_for_help(person1.id)
       expect(cac.allowed_to_access(person2.id.to_s)).to be_falsey
      end
      it 'should return true if asked_for_help array includes person_id' do
       cac.ask_for_help(person1.id.to_s)
       expect(cac.allowed_to_access(person1.id.to_s)).to be_truthy
      end
    end
  end
end







require "rails_helper"

describe AccessPolicies::Person, :dbclean => :after_each do
  
  let(:controller) { Exchanges::AgentsController.new }
  let(:some_person) {FactoryGirl.create(:person)}
  let(:any_person) {FactoryGirl.create(:person)}
  context 'authorize_agent_access_to_family' do
    describe 'employee cannot access family as agent' do
      subject { AccessPolicies::Person.new(user, controller) }
      let(:user) { FactoryGirl.create(:user, person: person)}
      let(:person) {FactoryGirl.create(:person) }
      it 'with no agent roles should fail' do
      	expect(controller).to receive(:security_exception)
      	expect(subject.authorize_agent_access_to_family(any_person.id)).to be_falsey
      end
      it 'succeeds for hbx_staff' do
        allow(user).to receive(:has_hbx_staff_role?).and_return(true)
        expect(controller).not_to receive(:security_exception)
        expect(subject.authorize_agent_access_to_family(any_person.id)).to be_truthy
      end

      it 'succeeds for csr with cac false' do
        allow(user).to receive(:has_csr_subrole?).and_return(true)
        expect(controller).not_to receive(:security_exception)
        expect(subject.authorize_agent_access_to_family(any_person.id)).to be_truthy
      end

      it 'fails for csr with cac true (Certified Applicant Counselor) with unauthorized persons' do
        csr_role= FactoryGirl.build(:csr_role, asked_for_help: [some_person.id.to_s], cac: true)
        user.person.update_attributes!(csr_role: csr_role)
        expect(controller).to receive(:security_exception)
        expect(subject.authorize_agent_access_to_family(any_person.id.to_s)).to be_falsey
      end

      it 'succeeds for csr with cac true (Certified Applicant Counselor) with an authorized persons' do
        csr_role= FactoryGirl.build(:csr_role, asked_for_help: [some_person.id.to_s], cac: true)
        user.person.update_attributes!(csr_role: csr_role)
        expect(controller).not_to receive(:security_exception)
        expect(subject.authorize_agent_access_to_family(some_person.id.to_s)).to be_truthy
      end

      it 'fails for assister with unauthorized persons' do
        allow(user).to receive(:has_assister_role?).and_return(true)
        assister_role= FactoryGirl.build(:assister_role, asked_for_help: [some_person.id.to_s])
        user.person.update_attributes!(assister_role: assister_role)
        expect(controller).to receive(:security_exception)
        expect(subject.authorize_agent_access_to_family(any_person.id.to_s)).to be_falsey
      end

      it 'succeeds for assister with an authorized persons' do
        allow(user).to receive(:has_assister_role?).and_return(true)
        assister_role= FactoryGirl.build(:assister_role, asked_for_help: [some_person.id.to_s])
        user.person.update_attributes!(assister_role: assister_role)
        expect(controller).not_to receive(:security_exception)
        expect(subject.authorize_agent_access_to_family(some_person.id.to_s)).to be_truthy
      end
      
      it 'fails for broker with person who did not hire broker' do
        allow(user).to receive(:has_broker_role?).and_return(true)
        broker_org = FactoryGirl.create(:broker_agency, fein: 100000000+rand(100000))
        bap = broker_org.broker_agency_profile
        broker_role = bap.primary_broker_role
        broker_role.update_attributes!(npn: 33000000 + rand(1000000))
        broker_role.update_attributes!(broker_agency_profile_id: bap.id)
        family = FactoryGirl.create(:family,:with_primary_family_member, e_case_id: rand(100000))
        allow(person).to receive(:broker_role).and_return(broker_role)
        expect(controller).to receive(:security_exception)
        expect(subject.authorize_agent_access_to_family(family.primary_applicant.person.id.to_s)).to be_falsey
      end

      it 'succeeds for broker with person who hired broker' do
        allow(user).to receive(:has_broker_role?).and_return(true)
        broker_org = FactoryGirl.create(:broker_agency, fein: 100000000+rand(100000))
        bap = broker_org.broker_agency_profile
        broker_role = bap.primary_broker_role
        broker_role.update_attributes!(npn: 33000000 + rand(1000000))
        broker_role.update_attributes!(broker_agency_profile_id: bap.id)
        family = FactoryGirl.create(:family,:with_primary_family_member, e_case_id: rand(100000))
        family.hire_broker_agency(broker_role.id)
        allow(person).to receive(:broker_role).and_return(broker_role)
        expect(controller).not_to receive(:security_exception)
        expect(subject.authorize_agent_access_to_family(family.primary_applicant.person.id.to_s)).to be_truthy
      end
    end
  end
end




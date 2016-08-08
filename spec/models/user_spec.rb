require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:gen_pass) { User.generate_valid_password }

  let(:valid_params) do
    {
      email: "test@test.com",
      oim_id: "testtest",
      password: gen_pass,
      password_confirmation: gen_pass,
      approved: true,
      person: {first_name: "john", last_name: "doe", ssn: "123456789"}
    }
  end

  describe 'user' do

    context 'when oim_id' do
      let(:params){valid_params.deep_merge!({oim_id: "user+name"})}
      it 'contains invalid characters' do
        expect(User.create(**params).errors[:oim_id].any?).to be_truthy
        expect(User.create(**params).errors[:oim_id]).to eq ["cannot contain special charcters ; # % = | + , \" > < \\ \/"]
      end
    end

    context 'when oim_id' do
      let(:params){valid_params.deep_merge!({oim_id: "user"})}
      it 'is too short' do
        expect(User.create(**params).errors[:oim_id].any?).to be_truthy
        expect(User.create(**params).errors[:oim_id]).to eq ["must be at least 8 characters"]
      end
    end

    context 'oim_id validation' do
      let(:params){valid_params}
      it {should validate_uniqueness_of(:oim_id).case_insensitive }
    end

    context 'when oim_id' do
      let(:params){valid_params.deep_merge!({oim_id: "useruseruseruseruseruseruseruseruseruseruseruseruseruseruseruser"})}
      it 'is too long' do
        expect(User.create(**params).errors[:oim_id].any?).to be_truthy
        expect(User.create(**params).errors[:oim_id]).to eq ["can NOT exceed 60 characters"]
      end
    end

    context 'when oim_id' do
      let(:params){valid_params.deep_merge!({oim_id: ""})}
      it 'is empty' do
        expect(User.create(**params).errors[:oim_id].any?).to be_truthy
        expect(User.create(**params).errors[:oim_id]).to eq ["can't be blank"]
      end
    end

    context 'when password' do
      let(:params){valid_params.deep_merge!({password: "",})}
      it 'is empty' do
        expect(User.create(**params).errors[:password].any?).to be_truthy
        expect(User.create(**params).errors[:password]).to eq ["can't be blank"]
        expect(User.create(**params).errors[:password_confirmation]).to eq ["doesn't match Password"]
      end
    end

    context 'when password' do
      let(:params){valid_params.deep_merge!({password: valid_params[:oim_id].capitalize + "aA1!"})}
      it 'contains username' do
        expect(User.create(**params).errors[:password].any?).to be_truthy
        expect(User.create(**params).errors[:password]).to eq ["cannot contain username"]
      end
    end

    context 'when password' do
      let(:params){valid_params.deep_merge!({password: "123456 6746464DDss"})}
      it 'does not contain valid complexity' do
        expect(User.create(**params).errors[:password].any?).to be_truthy
        expect(User.create(**params).errors[:password]).to eq ["must include at least one lowercase letter, one uppercase letter, one digit, and one character that is not a digit or letter or space"]
      end
    end

    context 'when password' do
      let(:params){valid_params.deep_merge!({password: "11E11@1ss"})}
      it 'has a character more than 4 times' do
        expect(User.create(**params).errors[:password].any?).to be_truthy
        expect(User.create(**params).errors[:password]).to eq ["cannot repeat any character more than 4 times"]
      end
    end

    context 'when password' do
      let(:params){valid_params.deep_merge!({password: "11E11@ss"})}
      it 'has only 3 alphabetical characters' do
        expect(User.create(**params).errors[:password].any?).to be_truthy
        expect(User.create(**params).errors[:password]).to eq ["must have at least 4 alphabetical characters"]
      end
    end

    context 'when password' do
      let(:params){valid_params.deep_merge!({password: "12_-66746464DDDss"})}
      it 'repeats a consecutive character more than once' do
        expect(User.create(**params).errors[:password].any?).to be_truthy
        expect(User.create(**params).errors[:password]).to eq ["must not repeat consecutive characters more than once"]
      end
    end

    context 'when password & password confirmation' do
      let(:params){valid_params.deep_merge!({password: "1Aa@"})}
      it 'does not match' do
        expect(User.create(**params).errors[:password].any?).to be_truthy
        expect(User.create(**params).errors[:password_confirmation].any?).to be_truthy
        expect(User.create(**params).errors[:password]).to eq ["must have at least 4 alphabetical characters", "is too short (minimum is 8 characters)"]
        expect(User.create(**params).errors[:password_confirmation]).to eq ["doesn't match Password"]
      end
    end

    context 'when associated person' do
      let(:params){valid_params}
      it 'first name is invalid' do
        params[:person][:first_name] = ""
        expect(User.create(**params).errors[:person].any?).to be_truthy
        expect(User.create(**params).errors[:person]).to eq ["is invalid"]
        expect(User.create(**params).person.errors[:first_name].any?).to be_truthy
        expect(User.create(**params).person.errors[:first_name]).to eq ["can't be blank"]
      end

      it 'last name is invalid' do
        params[:person][:last_name] = ""
        expect(User.create(**params).errors[:person].any?).to be_truthy
        expect(User.create(**params).errors[:person]).to eq ["is invalid"]
        expect(User.create(**params).person.errors[:last_name].any?).to be_truthy
        expect(User.create(**params).person.errors[:last_name]).to eq ["can't be blank"]
      end

      it 'ssn is invalid' do
        params[:person][:ssn] = "123"
        expect(User.create(**params).errors[:person].any?).to be_truthy
        expect(User.create(**params).errors[:person]).to eq ["is invalid"]
        expect(User.create(**params).person.errors[:ssn].any?).to be_truthy
        expect(User.create(**params).person.errors[:ssn]).to eq ["SSN must be 9 digits"]
      end
    end

    context "when all params are valid" do
      let(:params){valid_params}
      it "should not have errors on create" do
        record = User.create(**params)
        expect(record).to be_truthy
        expect(record.errors.messages.size).to eq 0
      end
    end

    context "roles" do
      let(:params){valid_params.deep_merge({roles: ["employee", "broker", "hbx_staff"]})}
      it "should return proper roles" do
        user = User.new(**params)
        person = FactoryGirl.create(:person)
        allow(user).to receive(:person).and_return(person)
        employer_staff_role =FactoryGirl.create(:employer_staff_role, person: person)
        #allow(person).to receive(:employee_roles).and_return([role])
        FactoryGirl.create(:employer_staff_role, person: person)
        #Deprecated. DO NOT USE.  Migrate to person.active_employee_roles.present?
        #expect(user.has_employee_role?).to be_truthy
        expect(user.has_employer_staff_role?).to be_truthy
        expect(user.has_broker_role?).to be_truthy
        expect(user.has_hbx_staff_role?).to be_truthy
      end
    end

    context "should instantiate person" do
      let(:params){valid_params}
      it "should build person" do
        user = User.new(**params)
        user.instantiate_person
        expect(user.person).to be_an_instance_of Person
      end
    end
  end
end

describe User do
  subject { User.new(:identity_final_decision_code => decision_code_value) }

  describe "with no identity final decision code" do
    let(:decision_code_value) { nil }
    it "should not be considered identity_verified" do
      expect(subject.identity_verified?).to eq false
    end
  end

  describe "with a non-successful final decision code" do
    let(:decision_code_value) { "lkdsjfaoifudjfnnkadjlkfajlafkl;f" }
    it "should not be considered identity_verified" do
      expect(subject.identity_verified?).to eq false
    end
  end

  describe "with a successful decision code" do
    let(:decision_code_value) { User::INTERACTIVE_IDENTITY_VERIFICATION_SUCCESS_CODE }
    it "should be considered identity_verified" do
      expect(subject.identity_verified?).to eq true
    end
  end
end

describe User do
  let(:person) { FactoryGirl.create(:person) }
  let(:user) { FactoryGirl.create(:user, person: person) }
  context "get_announcements_by_roles_and_portal" do
    before :each do
      Announcement.destroy_all
      Announcement::AUDIENCE_KINDS.each do |kind|
        FactoryGirl.create(:announcement, content: "msg for #{kind}", audiences: [kind])
      end
    end

    it "when employer_staff_role" do
      allow(user).to receive(:has_employer_staff_role?).and_return true
      expect(user.get_announcements_by_roles_and_portal("dc.org/employers/employer_profiles")).to eq ["msg for Employer"]
    end

    it "when employee_role" do
      allow(user).to receive(:has_employee_role?).and_return true
      expect(user.get_announcements_by_roles_and_portal("dc.org/employee")).to eq ["msg for Employee"]
    end

    it "when has active_employee_roles, but without employee_role role" do
      user.roles = []
      allow(person).to receive(:has_active_employee_role?).and_return true
      expect(user.get_announcements_by_roles_and_portal("dc.org/employee")).to eq ["msg for Employee"]
    end

    it "when visit families/home" do
      allow(user).to receive(:has_employee_role?).and_return true
      allow(user).to receive(:has_consumer_role?).and_return true
      expect(user.get_announcements_by_roles_and_portal("dc.org/families/home")).to eq ["msg for Employee", "msg for IVL"]
    end

    it "when broker_role" do
      user.roles = ['broker']
      expect(user.get_announcements_by_roles_and_portal("dc.org/broker_agencies")).to eq ["msg for Broker"]
    end

    it "when consumer_role" do
      allow(user).to receive(:has_consumer_role?).and_return true
      expect(user.get_announcements_by_roles_and_portal("dc.org/consumer")).to eq ["msg for IVL"]
    end

    it "when has active_consumer_roles, but without consumer_role role" do
      user.roles = []
      allow(person).to receive(:consumer_role).and_return true
      expect(user.get_announcements_by_roles_and_portal("dc.org/consumers")).to eq ["msg for IVL"]
    end

    it "when general_agency_staff" do
      user.roles = ['general_agency_staff']
      expect(user.get_announcements_by_roles_and_portal("dc.org/general_agencies")).to eq ["msg for GA"]
    end

    context "when broker_role and consumer_role" do
      it "with employer portal" do
        user.roles = ['consumer', 'broker']
        expect(user.get_announcements_by_roles_and_portal("dc.org/employers")).to eq []
      end

      it "with consumer portal" do
        user.roles = ['consumer', 'broker']
        allow(person).to receive(:consumer_role).and_return true
        expect(user.get_announcements_by_roles_and_portal("dc.org/consumer_role")).to eq ["msg for IVL"]
      end

      it "with broker agency portal" do
        user.roles = ['consumer', 'broker']
        expect(user.get_announcements_by_roles_and_portal("dc.org/broker_agencies")).to eq ["msg for Broker"]
      end
    end
  end

  describe "can_change_broker?" do
    context "with user" do
      it "should return true when hbx staff" do
        user.roles = ['hbx_staff']
        expect(user.can_change_broker?).to eq true
      end

      it "should return true when employer staff" do
        allow(person).to receive(:has_active_employer_staff_role?).and_return true
        expect(user.can_change_broker?).to eq true
      end

      it "should return false when broker role" do
        user.roles = ['broker']
        expect(user.can_change_broker?).to eq false
      end

      it "should return false when broker agency staff" do
        user.roles = ['broker_agency_staff']
        expect(user.can_change_broker?).to eq false
      end

      it "should return false when general agency staff" do
        user.roles = ['general_agency_staff']
        expect(user.can_change_broker?).to eq false
      end
    end
  end
end

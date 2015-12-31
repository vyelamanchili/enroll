require 'rails_helper'

RSpec.describe Exchanges::AgentsController, :dbclean => :after_each do
  describe 'Agent Controller behavior' do
    render_views
    let(:person_user){Person.new(first_name: 'fred', last_name: 'flintstone')}
    let(:person_insured){Person.create(first_name: 'wilma', last_name: 'rubble')}
    let(:current_user){FactoryGirl.create(:user)}
    let(:signed_in?){ true }
   
     before :each do
       allow(current_user).to receive(:person).and_return(person_user)
     end

    it 'renders home for CAC' do
      current_user.roles=['csr']
      current_user.person = person_user
      person_user.csr_role = FactoryGirl.build(:csr_role, cac: true)
      sign_in current_user
      get :home
      expect(response).to have_http_status(:success)
      expect(response).to render_template("exchanges/agents/home")
      expect(response.body).to match(/Certified Applicant Counselor/)
    end

    it 'renders home for CSR' do
      current_user.roles=['csr']
      current_user.person = person_user
      person_user.csr_role = FactoryGirl.build(:csr_role, cac: false)
      sign_in current_user
      get :home
      expect(response).to have_http_status(:success)
      expect(response).to render_template("exchanges/agents/home")
    end
    
    it 'begins enrollment' do
      sign_in current_user
      get :begin_employee_enrollment
      expect(response).to have_http_status(:redirect)
    end

    describe '#resume_enrollment'  do
      it 'raises exception if no authorized roles' do
        sign_in current_user
        get :resume_enrollment
        expect(response).to redirect_to(root_path)
      end
      it 'succeeds if hbx_staff_role, insured with no roles' do
        allow(current_user).to receive(:has_hbx_staff_role?).and_return(true)
        allow(Person).to receive(:find).and_return(person_insured)
        current_user.roles=['hbx_staff']
        current_user.save
        sign_in current_user
        get :resume_enrollment
        expect(response).to redirect_to(family_account_path)
      end
      it 'succeeds if csr_subrole, insured with no roles' do
        allow(current_user).to receive(:has_csr_subrole?).and_return(true)
        allow(Person).to receive(:find).and_return(person_insured)
        current_user.roles=['csr']
        current_user.save
        sign_in current_user
        get :resume_enrollment
        expect(response).to redirect_to(family_account_path)
      end
      it 'raises security_exception if cac_subrole accesses wrong person' do
        allow(current_user).to receive(:has_cac_subrole?).and_return(true)
        agent = FactoryGirl.create(:csr_role, cac: true)
        insured_id = person_insured.id.to_s
        allow(current_user).to receive(:person).and_return(agent.person)
        current_user.roles=['csr']
        current_user.save
        sign_in current_user
        expect{get :resume_enrollment, person_id: insured_id}.to raise_error(ActionController::RoutingError)
      end
      it 'succeeds if cac_subrole accesses authorized person' do
        allow(current_user).to receive(:has_cac_subrole?).and_return(true)
        agent = FactoryGirl.create(:csr_role, cac: true)
        insured_id = person_insured.id.to_s
        agent.ask_for_help insured_id
        allow(current_user).to receive(:person).and_return(agent.person)
        current_user.roles=['csr']
        current_user.save
        sign_in current_user
        get :resume_enrollment, person_id: insured_id
        expect(response).to redirect_to(family_account_path)
      end
      it 'raises security_exception if assister_role accesses wrong person' do
        allow(current_user).to receive(:has_assister_role?).and_return(true)
        agent = FactoryGirl.create(:assister_role)
        insured_id = person_insured.id.to_s
        allow(current_user).to receive(:person).and_return(agent.person)
        current_user.roles=['assister']
        current_user.save
        sign_in current_user
        expect{get :resume_enrollment, person_id: insured_id}.to raise_error(ActionController::RoutingError)
      end
      it 'succeeds if assister_role accesses authorized person' do
        allow(current_user).to receive(:has_assister_role?).and_return(true)
        agent = FactoryGirl.create(:assister_role)
        insured_id = person_insured.id.to_s
        agent.ask_for_help insured_id
        allow(current_user).to receive(:person).and_return(agent.person)
        current_user.roles=['assister']
        current_user.save
        sign_in current_user
        get :resume_enrollment, person_id: insured_id
        expect(response).to redirect_to(family_account_path)
      end

    end
  end
end

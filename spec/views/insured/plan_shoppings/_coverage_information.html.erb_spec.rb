require "rails_helper"

RSpec.describe "insured/plan_shoppings/_coverage_information.html.erb" do

  let(:employee_role){FactoryGirl.create(:employee_role)}
  let(:plan){FactoryGirl.create(:plan)}
  let(:benefit_group){ FactoryGirl.build(:benefit_group) }
  let(:hbx_enrollment){ HbxEnrollment.new(benefit_group: benefit_group, employee_role: employee_role, effective_on: 1.month.ago.to_date, updated_at: DateTime.now  ) }
  let(:person) { FactoryGirl.create(:person)}
  let(:terminate_date) { TimeKeeper.date_of_record.end_of_month }

  context "terminate" do
    before :each do
      @person = employee_role.person
      @plan = plan
      @enrollment = hbx_enrollment
      @benefit_group = @enrollment.benefit_group
      @reference_plan = @benefit_group.reference_plan
      @plan = PlanCostDecorator.new(@plan, @enrollment, @benefit_group, @reference_plan)
      assign :terminate, 'terminate'
      assign :enrollment, hbx_enrollment
      assign :terminate_date, terminate_date
      render "insured/plan_shoppings/coverage_information"
    end

    it "should display the terminate date" do
      expect(rendered).to have_content("Termination Date")
      expect(rendered).to have_content("#{terminate_date.strftime('%m/%d/%Y')}")
    end
  end
end

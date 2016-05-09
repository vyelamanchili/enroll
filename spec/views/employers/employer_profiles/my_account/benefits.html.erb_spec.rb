require "rails_helper"

RSpec.describe "employers/employer_profiles/my_account/_benefits.html.erb" do

  context "Plan year display" do

    let(:employer_profile) { FactoryGirl.build_stubbed(:employer_profile) }
    let(:plan_year) { FactoryGirl.build_stubbed(:plan_year) }
    let(:benefit_group) { FactoryGirl.build_stubbed(:benefit_group, :with_valid_dental, plan_year: plan_year ) }
    let(:plan) { FactoryGirl.build_stubbed(:plan) }
    let(:user) { FactoryGirl.create(:user) }

    before :each do
      sign_in(user)
      allow(benefit_group).to receive(:reference_plan).and_return(plan)
      allow(plan_year).to receive(:benefit_groups).and_return([benefit_group])
      allow(benefit_group).to receive(:effective_on_offset).and_return 30
      assign(:plan_years, [plan_year])
      assign(:employer_profile, employer_profile)
    end

    it "should display contribution pct by integer" do
      render "employers/employer_profiles/my_account/benefits"
      expect(rendered).to match(/Benefits - Coverage You Offer/)
      plan_year.benefit_groups.first.relationship_benefits.map(&:premium_pct).each do |pct|
        expect(rendered).to match "#{pct.to_i}"
      end
    end

    it "should display title by effective_on_offset" do
      render "employers/employer_profiles/my_account/benefits"
      expect(rendered).to match /Date of hire following 30 days/
    end

    it "should display title by benefit groups coverage year" do
      render "employers/employer_profiles/my_account/benefits"
      expect(rendered).to match /Coverage Year/
      expect(rendered).to have_selector("p", text: "#{plan_year.start_on.to_date.to_formatted_s(:long_ordinal)} - #{plan_year.end_on.to_date.to_formatted_s(:long_ordinal)}")
    end

    it "should display the benfit group description" do
      render "employers/employer_profiles/my_account/benefits"
      expect(rendered).to have_selector("h5", text: "my first benefit group")
    end

    it "should display a link to custom dental plans modal" do
      render "employers/employer_profiles/my_account/benefits"
      expect(rendered).to have_selector("a", text: "View Plans")
    end
  end

  context "Plan year" do
    let(:employer_profile) { FactoryGirl.build_stubbed(:employer_profile) }
    let(:plan_year) { FactoryGirl.build_stubbed(:plan_year, :aasm_state => 'renewing_draft') }
    let(:published_plan_year) { FactoryGirl.build_stubbed(:plan_year, :aasm_state => 'active') }
    let(:benefit_group) { FactoryGirl.build_stubbed(:benefit_group, :with_valid_dental, plan_year: plan_year ) }
    let(:plan) { FactoryGirl.build_stubbed(:plan) }
    let(:user) { FactoryGirl.create(:user) }

    before :each do
      sign_in(user)
      allow(benefit_group).to receive(:reference_plan).and_return(plan)
      allow(plan_year).to receive(:benefit_groups).and_return([benefit_group])
      allow(benefit_group).to receive(:effective_on_offset).and_return 30
      assign(:plan_years, [plan_year])
      assign(:employer_profile, employer_profile)
    end

    context "when overlapping published plan years present "do

      before do
        allow(plan_year).to receive(:overlapping_published_plan_years).and_return([published_plan_year])
      end

      it "should not display publish button" do
        render "employers/employer_profiles/my_account/benefits"
        expect(rendered).not_to have_selector("a", text: "Publish Plan Year")
        expect(rendered).to have_selector("a", text: "Edit Plan Year")
      end
    end

    context "when overlapping published plan years present "do
      before do
        allow(plan_year).to receive(:overlapping_published_plan_years).and_return([])
      end

      it "should display publish button" do
        render "employers/employer_profiles/my_account/benefits"
        expect(rendered).to have_selector("a", text: "Publish Plan Year")
        expect(rendered).to have_selector("a", text: "Edit Plan Year")
      end
    end
  end
end

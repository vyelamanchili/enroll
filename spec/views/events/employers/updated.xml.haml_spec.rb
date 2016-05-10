require 'rails_helper'
require File.join(Rails.root, "spec", "support", "acapi_vocabulary_spec_helpers")

RSpec.describe "events/employer/updated.haml.erb" do
  let(:legal_name) { "A Legal Employer Name" }
  let(:fein) { "867530900" }
  let(:entity_kind) { "c_corporation" }

  let(:organization) { Organization.new(:legal_name => legal_name, :fein => fein, :is_active => false) }

  describe "given a single plan year" do
    include AcapiVocabularySpecHelpers

    before(:all) do
      download_vocabularies
    end

    let(:plan_year) { PlanYear.new(:aasm_state => "published", :created_at => DateTime.now, :start_on => DateTime.now, :open_enrollment_start_on => DateTime.now, :open_enrollment_end_on => DateTime.now) }
    let(:employer) { EmployerProfile.new(:organization => organization, :plan_years => [plan_year], :entity_kind => entity_kind) }

    before :each do
      render :template => "events/employers/updated", :locals => {:employer => employer}
    end

    it "should have one plan year" do
      expect(rendered).to have_xpath("//plan_years/plan_year")
    end

    it "should be schema valid" do
      expect(validate_with_schema(Nokogiri::XML(rendered))).to eq []
    end

    context "with dental plans" do

      let(:benefit_group) { bg = FactoryGirl.create(:benefit_group, plan_year: plan_year);
      bg.elected_dental_plans = [FactoryGirl.create(:plan, name: "new dental plan", coverage_kind: 'dental',
                                                    dental_level: 'high'),
                                 FactoryGirl.create(:plan, name: "new dental plan2", coverage_kind: 'dental',
                                                                                              dental_level: 'high')];
      bg.elected_plans = [FactoryGirl.create(:plan, name: "new health plan", coverage_kind: 'health',
                                             metal_level: 'silver')];
      bg.reference_plan_id = bg.elected_plans.first.id
      bg }

      context "dental_reference_plan for the benefit group is assigned" do

        before(:each) do
          benefit_group.dental_reference_plan_id = benefit_group.elected_dental_plans.first.id
          benefit_group.save!
        end

        it "shows the dental plans and the health plan in xml" do
          render :template => "events/employers/updated", :locals => {:employer => employer}
          expect(rendered).to have_xpath("//benefit_group/elected_plans/elected_plan/name",:text => "new health plan")
          expect(rendered).to have_xpath("//benefit_group/elected_plans/elected_plan/name",:text => "new dental plan")
          expect(rendered).to have_xpath("//benefit_group/elected_plans/elected_plan/name",:text => "new dental plan2")
        end
      end

      context "dental_reference_plan for the benefit group is not assigned" do
        before(:each) do
          benefit_group.dental_reference_plan_id = nil
          benefit_group.save!
        end

        it "will not show the dental plans in xml, only health plans will be shown" do
          render :template => "events/employers/updated", :locals => {:employer => employer}
          expect(rendered).to have_xpath("//benefit_group/elected_plans/elected_plan/name",:text => "new health plan")
          expect(rendered).not_to have_xpath("//benefit_group/elected_plans/elected_plan/name",:text => "new dental plan")
          expect(rendered).not_to have_xpath("//benefit_group/elected_plans/elected_plan/name",:text => "new dental plan2")
        end
      end
    end

    context "staff is owner" do
      let(:staff_and_owner) { FactoryGirl.create(:person) }

      before do
        allow(employer).to receive(:staff_roles).and_return([staff_and_owner])
        allow(employer).to receive(:owners).and_return([staff_and_owner])
        render :template => "events/employers/updated", :locals => {:employer => employer}
      end

      it "does not included the contact person twice" do
        expect(rendered).to have_selector('contact', count: 1)
      end
    end

  end

  (1..15).to_a.each do |rnd|

    describe "given a generated employer, round #{rnd}" do
      include AcapiVocabularySpecHelpers

      before(:all) do
        download_vocabularies
      end

      let(:employer) { FactoryGirl.build_stubbed :generative_employer_profile }

      before :each do
        render :template => "events/employers/updated", :locals => {:employer => employer}
      end

      it "should be schema valid" do
        expect(validate_with_schema(Nokogiri::XML(rendered))).to eq []
      end

    end

  end
end

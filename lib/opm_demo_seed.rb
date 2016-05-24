class OpmDemoSeed
 
    def self.execute
      employer_profile, census_employee = seed_congressional_employer
      plan_year = employer_profile.active_plan_year

      person = FactoryGirl.create(:person, first_name: 'John', last_name: 'Smith', dob: '1966-10-10'.to_date, ssn: '191454728', gender: 'male')
      person.employee_roles.create(employer_profile: employer_profile, hired_on: census_employee.hired_on, census_employee_id: census_employee.id)

      family = FactoryGirl.create(:family, :with_primary_family_member, person: person)
      family.active_household.immediate_family_coverage_household.add_coverage_household_member(family.family_members.first)
      family.save!

      Forms::FamilyMember.new({"first_name"=>"Jane", "last_name"=>"Smith", "dob"=>"1971-05-01", "ssn"=>"519-20-1029", "no_ssn"=>"0", "relationship"=>"spouse", "gender"=>"female", "family_id"=> family.id}).save
      create_hbx_enrollment(person, census_employee, Date.new(2016,1,1))

      address = person.addresses.first
      person.addresses = []
      person.save!

      employer_profile, census_employee = seed_renewing_employer
      plan_year = employer_profile.active_plan_year

      person = FactoryGirl.create(:person, first_name: 'Ben', last_name: 'Thompson', dob: '1956-10-10'.to_date, ssn: '176456728', gender: 'male')
      person.employee_roles.create(employer_profile: employer_profile, hired_on: census_employee.hired_on, census_employee_id: census_employee.id)

      family = FactoryGirl.create(:family, :with_primary_family_member, person: person)
      family.active_household.immediate_family_coverage_household.add_coverage_household_member(family.family_members.first)
      family.save!

      Forms::FamilyMember.new({"first_name"=>"Catherine", "last_name"=>"Thompson", "dob"=>"1965-1-15", "ssn"=>"566-22-8829", "no_ssn"=>"0", "relationship"=>"spouse", "gender"=>"female", "family_id"=> family.id}).save
      create_hbx_enrollment(person, census_employee, Date.new(2015,7,1))

      address = person.addresses.first
      person.addresses = []
      person.save!
    end

  class << self 
    def seed_congressional_employer
      puts "Seeding Congressional Employer.."
      organization = FactoryGirl.create :organization, legal_name: "United States Senate", dba: "United State Senate", fein: "671551122"
      employer_profile = FactoryGirl.create :employer_profile, organization: organization

      create_office_location(organization)

      plan_year = FactoryGirl.create(:plan_year,
        start_on: Date.new(2016,1,1),
        end_on: Date.new(2016,12,31),
        open_enrollment_start_on: Date.new(2015,12,1),
        open_enrollment_end_on: Date.new(2015,12,13),
        employer_profile: employer_profile,
        aasm_state: 'renewing_enrolled'
        )

      benefit_group = build_benefit_group(plan_year, "Benefit Package 2016", true)
      benefit_group.metal_level_for_elected_plan = 'gold'
      benefit_group.elected_plans = benefit_group.elected_plans_by_option_kind
      benefit_group.save!
      plan_year.activate!

      census_employee = FactoryGirl.create :census_employee, employer_profile: employer_profile,
      first_name: 'John', last_name: 'Smith', dob: '1966-10-10'.to_date, ssn: '191454728', hired_on: Date.new(2015,5,1)

      census_employee.add_benefit_group_assignment benefit_group, benefit_group.start_on

      return employer_profile, census_employee
    end

    def create_office_location(organization)
      office_location = OfficeLocation.new(:is_primary => true)
      office_location.address= Address.new(:address_1 => '609 H St NE', :city => 'Washington', :state => 'DC', :zip => 20002, :kind => 'work')
      office_location.phone=Phone.new(kind: 'work', area_code: "202", number: "1111112", extension: "2" )
      organization.office_locations = [office_location]
      organization.save!
    end

    def seed_renewing_employer
      puts "Seeding Renewing Employer.."

      organization = FactoryGirl.create :organization, legal_name: "DC Professionals", dba: "DC Professionals", fein: "671551188"
      employer_profile = FactoryGirl.create :employer_profile, organization: organization

      create_office_location(organization)

      plan_year = FactoryGirl.create(:plan_year,
        start_on: Date.new(2015,7,1),
        end_on: Date.new(2016,6,30),
        open_enrollment_start_on: Date.new(2015,6,1),
        open_enrollment_end_on: Date.new(2015,6,10),
        employer_profile: employer_profile,
        aasm_state: 'active'
      )

      benefit_group = build_benefit_group(plan_year, "DC Benefits")
      benefit_group.metal_level_for_elected_plan = 'gold'
      benefit_group.elected_plans = benefit_group.elected_plans_by_option_kind
      benefit_group.save!

      census_employee = FactoryGirl.create :census_employee, employer_profile: employer_profile,
      first_name: 'Ben', last_name: 'Thompson', dob: '1956-10-10'.to_date, ssn: '176456728', hired_on: Date.new(2015,5,1)

      census_employee.add_benefit_group_assignment benefit_group, benefit_group.start_on

      renewal_factory = Factories::PlanYearRenewalFactory.new
      renewal_factory.employer_profile = employer_profile
      renewal_factory.is_congress = false
      renewal_factory.renew

      return employer_profile, census_employee
    end

    def build_benefit_group(plan_year, title, is_congress = false)
      relationship_benefits = [
        RelationshipBenefit.new(offered: true, relationship: :employee, premium_pct: (is_congress ? 75 : 100)),
        RelationshipBenefit.new(offered: true, relationship: :spouse, premium_pct: 75),
        RelationshipBenefit.new(offered: false, relationship: :domestic_partner, premium_pct: 0),
        RelationshipBenefit.new(offered: true, relationship: :child_under_26, premium_pct: 75),
        RelationshipBenefit.new(offered: true, relationship: :child_26_and_older, premium_pct: 75)
      ]

      plan_year.benefit_groups.new({
        title: title,
        effective_on_kind: "first_of_month", 
        terminate_on_kind: "end_of_month",
        plan_option_kind: "single_carrier", 
        effective_on_offset: 0,
        is_congress: is_congress,
        reference_plan_id: reference_plan(is_congress),
        relationship_benefits: relationship_benefits,
        default: true
        })
    end

    def create_hbx_enrollment(person, census_employee, effective_on)
      family = person.primary_family
      benefit_group = census_employee.active_benefit_group_assignment.benefit_group

      hbx_enrollment = FactoryGirl.create(:hbx_enrollment,
        household: family.latest_household,
        coverage_kind: "health",
        effective_on: effective_on,
        enrollment_kind: "open_enrollment",
        kind: "employer_sponsored",
        submitted_at: effective_on - 1.month,
        benefit_group_id: benefit_group.id,
        employee_role_id: person.employee_roles.first.id,
        benefit_group_assignment_id: census_employee.active_benefit_group_assignment.id,
        plan_id: reference_plan(benefit_group.is_congress)
        )

      family.reload
      family.active_household.immediate_family_coverage_household.coverage_household_members.each do |coverage_member|
        enrollment_member = HbxEnrollmentMember.new_from(coverage_household_member: coverage_member)
        enrollment_member.eligibility_date = effective_on
        enrollment_member.coverage_start_on = effective_on
        hbx_enrollment.hbx_enrollment_members << enrollment_member
      end

      hbx_enrollment.save!
    end

    def reference_plan(is_congress)
      is_congress ? Plan.where(:hios_id => "86052DC0440010-01", :active_year => 2016).first.id : Plan.where(:hios_id => "86052DC0560005-01", :active_year => 2015).first.id
    end
  end
end


namespace :migrations do
  desc "create employer plan year"
  task :create_new_plan_year, [:fein, :start_on] => [:environment] do |task, args|

    employer_profile = EmployerProfile.find_by_fein(args[:fein])
    start_on = Date.strptime(args[:start_on], "%m/%d/%Y")

    benefit_group_assignment_create = Proc.new do |employer_profile|
      plan_year = employer_profile.plan_years.where(:start_on => start_on).first
      benefit_group = plan_year.benefit_groups.first
      employer_profile.census_employees.non_terminated.each{|ce| ce.add_benefit_group_assignment(benefit_group)}
    end

    plan_year_create = Proc.new do |employer_profile|
      prev_plan_year = employer_profile.plan_years.first

      new_plan_year = employer_profile.plan_years.build({
        start_on: start_on,
        end_on: start_on + 1.year - 1.day,
        open_enrollment_start_on: start_on - 2.months,
        open_enrollment_end_on: start_on - 1.month + 9.days,
        fte_count: prev_plan_year.fte_count,
        pte_count: prev_plan_year.pte_count,
        msp_count: prev_plan_year.msp_count
        })

      if new_plan_year.save
        add_benefit_groups(prev_plan_year, new_plan_year, employer_profile)
      else
        puts "plan year not saved!"
      end
    end
    
    plan_year_create.call employer_profile
    benefit_group_assignment_create.call employer_profile

    def add_benefit_groups(active_plan_year, new_plan_year, employer_profile)
      active_plan_year.benefit_groups.each do |active_group|

        index = active_plan_year.benefit_groups.index(active_group) + 1
        new_year = active_plan_year.start_on.year + 1

        reference_plan_id = Plan.find(active_group.reference_plan_id).renewal_plan_id
        if reference_plan_id.blank?
          raise PlanYearRenewalFactoryError, "Unable to find renewal for referenence plan: Id #{active_group.reference_plan.id} Year #{active_group.reference_plan.active_year} Hios #{active_group.reference_plan.hios_id}"
        end

        elected_plan_ids = reference_plan_ids(active_group)
        if elected_plan_ids.blank?
          raise PlanYearRenewalFactoryError, "Unable to find renewal for elected plans: #{active_group.elected_plan_ids}"
        end

        new_group = new_plan_year.benefit_groups.build({
          title: "#{active_group.title} (#{new_year})",
          effective_on_kind: "first_of_month",
          terminate_on_kind: active_group.terminate_on_kind,
          plan_option_kind: active_group.plan_option_kind,
          default: active_group.default,
          effective_on_offset: active_group.effective_on_offset,
          employer_max_amt_in_cents: active_group.employer_max_amt_in_cents,
          relationship_benefits: active_group.relationship_benefits,
          reference_plan_id: reference_plan_id,
          elected_plan_ids: elected_plan_ids,
          is_congress: false
          })

        if new_group.save
          update_census_employees(new_group, employer_profile)
        else
          raise "Error saving benefit_group"
        end
      end
    end

    def reference_plan_ids(active_group)
      start_on_year = (active_group.start_on + 1.year).year
      if active_group.plan_option_kind == "single_carrier"
        Plan.by_active_year(start_on_year).shop_market.health_coverage.by_carrier_profile(active_group.reference_plan.carrier_profile).and(hios_id: /-01/).map(&:id)
      elsif active_group.plan_option_kind == "metal_level"
        Plan.by_active_year(start_on_year).shop_market.health_coverage.by_metal_level(active_group.reference_plan.metal_level).and(hios_id: /-01/).map(&:id)
      else
        Plan.where(:id.in => active_group.elected_plan_ids).map(&:renewal_plan_id)
      end
    end

    def update_census_employees(new_group, employer_profile)
      employer_profile.census_employees.non_terminated.each do |census_employee|
        census_employee.add_benefit_group_assignment(new_group, new_group.start_on)
        census_employee.save!
        census_employee.benefit_group_assignments.to_a.last.make_active
      end
    end
  end
end

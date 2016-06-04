namespace :migrations do

  desc "Cancel employer plan year"
  task :cancel_plan_year, [:fein, :start_on] => [:environment] do |task, args|
    
    employer_profile = EmployerProfile.find_by_fein(args[:fein])
    if employer_profile.blank?
      return
    end

    start_on = Date.strptime(args[:start_on], "%m/%d/%Y")
    plan_year = employer_profile.plan_years.published_or_renewing_published.where(:start_on => start_on).first
    if plan_year.blank?
      return
    end

    hbx_enrollments = HbxEnrollment.find_by_benefit_groups(plan_year.benefit_groups)
    hbx_enrollments.each do |enrollment|
      enrollment.cancel_coverage!
    end

    benefit_group_ids = plan_year.benefit_groups.map(&:id)
    employer_profile.census_employees.each do |census_employee|
      census_employee.benefit_group_assignments.where(:"benefit_group_id".in => benefit_group_ids).each do |bg_assignment|
        bg_assignment.update_attributes(is_active: false)
      end
    end

    plan_year.cancel!
    employer_profile.revert_application! if employer_profile.may_revert_application?
    puts "cancellation successful!" 
  end
end
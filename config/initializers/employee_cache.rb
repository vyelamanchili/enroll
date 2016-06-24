if Rails.application.config.eager_load
  CensusEmployee.all.each do |ce|
    ce.benefit_group_assignments.each do |bga|
      ce.has_active_health_coverage?(bga.plan_year) if bga.plan_year.present?
    end
  end

  #EmployerProfile.all.each do |ep|
  #  ep.active_plan_year.enrolled if ep.active_plan_year.present?
  #end
end

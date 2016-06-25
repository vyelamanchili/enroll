if Rails.application.config.eager_load
  CensusEmployee.all.each do |ce|
    ce.benefit_group_assignments.each do |bga|
      ce.has_active_health_coverage?(bga.plan_year) if bga.plan_year.present?
    end
  end

  EmployerProfile.all.each do |ep|
    ep.active_plan_year.enrolled if ep.active_plan_year.present?
  end

  Family.all.each do |f|
    if f.latest_household && f.latest_household.hbx_enrollments.present?
      f.latest_household.hbx_enrollments.each do |hbx|
        hbx.decorated_hbx_enrollment
      end
    end
  end

  # for plan cache
  Caches::PlanDetails.load_record_cache!

  Organization.exists(carrier_profile: true).map do |org|
    Plan.valid_shop_health_plans('carrier', org.carrier_profile.id)
  end

  Plan::REFERENCE_PLAN_METAL_LEVELS.map do |metal_level|
    Plan.valid_shop_health_plans('metal_level', metal_level)
  end
end

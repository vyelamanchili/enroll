Organization.exists(carrier_profile: true).map do |org|
  Plan.valid_shop_health_plans('carrier', org.carrier_profile.id)
end

Plan::REFERENCE_PLAN_METAL_LEVELS.map do |metal_level|
  Plan.valid_shop_health_plans('metal_level', metal_level)
end

$quote_shop_health_plans = Plan.shop_health_by_active_year(2016).all.entries
puts 'here', $quote_shop_health_plans.count
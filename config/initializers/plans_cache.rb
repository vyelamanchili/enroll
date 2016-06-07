Organization.exists(carrier_profile: true).map do |org|
  Plan.valid_shop_health_plans('carrier', org.carrier_profile.id)
end

Plan::REFERENCE_PLAN_METAL_LEVELS.map do |metal_level|
  Plan.valid_shop_health_plans('metal_level', metal_level)
end

$quote_shop_health_plans = Plan.shop_health_by_active_year(2016).all.entries

def build_plan_selectors market_kind='shop', coverage_kind='health'
  #TODO extend to Dental
  plans = $quote_shop_health_plans
  selectors = {}
  selectors[:metals] =      plans.map{|p| p.metal_level}.uniq.append('any')
  selectors[:carriers] =    plans.map{|p|
    [ p.carrier_profile.legal_name, p.carrier_profile.abbrev ]
    }.uniq.append(['any','any'])
  selectors[:plan_types] =  plans.map{|p| p.plan_type}.uniq.append('any')
  selectors[:dc_network] =  ['true', 'false', 'any']
  selectors[:nationwide] =  ['true', 'false', 'any']
  selectors
end

def build_plan_features market_kind='shop', coverage_kind='health'
  #TODO Extend to Dental
  plans = $quote_shop_health_plans
  feature_array = []
  plans.each{|plan|

    characteristics = {}
    characteristics['plan_id'] = plan.id.to_s
    characteristics['metal'] = plan.metal_level
    characteristics['carrier'] = plan.carrier_profile.organization.legal_name
    characteristics['plan_type'] = plan.plan_type
    characteristics['deductible'] = plan.deductible_int
    characteristics['carrier_abbrev'] = plan.carrier_profile.abbrev
    characteristics['nationwide'] = plan.nationwide
    characteristics['dc_in_network'] = plan.dc_in_network

    if plan.deductible_int.present?
      feature_array << characteristics
    else   
      log("ERROR: No deductible found for Plan: #{p.name}", {:severity => "error"})
    end
  }
  feature_array
end

$quote_shop_health_selectors = build_plan_selectors
$quote_shop_health_plan_features = build_plan_features
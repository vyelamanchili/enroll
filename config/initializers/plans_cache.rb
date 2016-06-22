include Acapi::Notifiers

Organization.exists(carrier_profile: true).map do |org|
  Plan.valid_shop_health_plans('carrier', org.carrier_profile.id)
end

Plan::REFERENCE_PLAN_METAL_LEVELS.map do |metal_level|
  Plan.valid_shop_health_plans('metal_level', metal_level)
end
include Acapi::Notifiers
$quote_shop_health_plans = Plan.shop_health_by_active_year(2016).all.entries
$quote_shop_dental_plans = Plan.shop_dental_by_active_year(2016).all.entries

def build_plan_selectors market_kind='shop', coverage_kind='health'
  plans = coverage_kind == 'health' ? $quote_shop_health_plans : $quote_shop_dental_plans
  selectors = {}
  if coverage_kind == 'dental'
    selectors[:dental_levels] = plans.map{|p| p.dental_level}.uniq.append('any')
  else
    selectors[:metals] = plans.map{|p| p.metal_level}.uniq.append('any')
  end
  selectors[:carriers] = plans.map{|p|
    [ p.carrier_profile.legal_name, p.carrier_profile.abbrev, p.carrier_profile.id ]
    }.uniq.append(['any','any'])
  selectors[:plan_types] =  plans.map{|p| p.plan_type}.uniq.append('any')
  selectors[:dc_network] =  ['true', 'false', 'any']
  selectors[:nationwide] =  ['true', 'false', 'any']
  selectors
end

def build_plan_features market_kind='shop', coverage_kind='health'
  plans = coverage_kind == 'health' ? $quote_shop_health_plans : $quote_shop_dental_plans
  feature_array = []
  plans.each{|plan|

    characteristics = {}
    characteristics['plan_id'] = plan.id.to_s
    if coverage_kind == 'dental'
      characteristics['dental_level'] = plan.dental_level
    else
      characteristics['metal'] = plan.metal_level
    end
    characteristics['carrier'] = plan.carrier_profile.organization.legal_name
    characteristics['plan_type'] = plan.plan_type
    characteristics['deductible'] = plan.deductible_int
    characteristics['carrier_abbrev'] = plan.carrier_profile.abbrev
    characteristics['nationwide'] = plan.nationwide
    characteristics['dc_in_network'] = plan.dc_in_network

    if plan.deductible_int.present?
      feature_array << characteristics
    else
      log("ERROR: No deductible found for Plan: #{p.try(:name)}, ID: #{plan.id}", {:severity => "error"})
    end
  }
  feature_array
end

$quote_shop_health_selectors = build_plan_selectors
$quote_shop_health_plan_features = build_plan_features
$quote_shop_dental_selectors = build_plan_selectors('shop', 'dental')
$quote_shop_dental_plan_features = build_plan_features('shop', 'dental')
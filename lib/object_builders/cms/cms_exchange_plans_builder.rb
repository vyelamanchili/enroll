class CmsExchangePlansBuilder

  SHOP_SMALL_GROUP = "SHOP (Small Group)"
  SHOP = "shop"
  INDIVIDUAL = "individual"
  HEALTH = "health"
  DENTAL = "dental"

  def initialize(data)
    @plan_data = data.sheet(0)
    @last_row = @plan_data.last_row
  end

  def run
    iterate_plans_hash
  end

  def iterate_plans_hash
    assign_headers
    (2..@last_row).each do |row_number|
      @plan = @plan_data.row(row_number)
      assign_params
      build_and_save_plan
    end
  end

  def assign_headers
    @headers = Hash.new
    @plan_data.row(1).each_with_index {|header,i|
      @headers[header] = i
    }
  end

  def assign_params
    nationwide, dc_in_network = parse_nation_wide_and_dc_in_network
    {
      active_year: @plan[@headers["BusinessYear"]],
      market: @plan[@headers["MarketCoverage"]] == SHOP_SMALL_GROUP ? SHOP : INDIVIDUAL,
      coverage_kind: @plan[@headers["DentalOnlyPlan"]].downcase == "no" ? HEALTH : DENTAL,
      carrier_profile_id: get_carrier_profile_id,
      metal_level: parse_metal_level,
      hios_id: @metal_level == DENTAL ? @plan[@headers["PlanId"]].split("-").first : @plan[@headers["PlanId"]],
      hios_base_id: @plan[@headers["PlanId"]].split("-").first,
      csr_variant_id: @metal_level == DENTAL ? "" : @plan[@headers["PlanId"]].split("-").last,
      name: @plan[@headers["PlanMarketingName"]],
      ehb: @plan[@headers["EHBPercentPremiumS4"]],
      nationwide: nationwide,
      dc_in_network: dc_in_network,
      plan_type: @plan[@headers["PlanType"]].downcase,
    }
  end

  def get_carrier_profile_id
    org = Organization.where(
      "carrier_profile.network_id" => @plan[@headers["NetworkId"]],
      "carrier_profile.issuer_id" => @plan[@headers["IssuerId"]]
      ).first
    org.carrier_profile.id
  end

  def build_and_save_plan
    plan = Plan.new(assign_params)
    if plan.save!
    else
      puts "unable to save plan :::: #{plan.hios_id}"
    end
  end

  def parse_nation_wide_and_dc_in_network
    if @plan[@headers["NationalNetwork"]].downcase.strip == "yes"
      ["true", "false"]
    else
      ["false", "true"]
    end
  end

  def parse_metal_level
    @metal_level = if ["high","low"].include?(@plan[@headers["MetalLevel"]].downcase)
      DENTAL
    else
      @plan[@headers["MetalLevel"]].downcase
    end
  end

end
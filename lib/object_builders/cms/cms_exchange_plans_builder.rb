class CmsExchangePlansBuilder < CmsParentBuilder

  SHOP_SMALL_GROUP = "SHOP (Small Group)"
  SHOP = "shop"
  INDIVIDUAL = "individual"
  HEALTH = "health"
  DENTAL = "dental"
  CATASTROPHIC = "catastrophic"

  def run
    iterate_plans_hash
  end

  def iterate_plans_hash
    (@first_row..@last_row).each do |row_number|
      @plan = @data.row(row_number)
      next if qhp_params[:state_postal_code] != "NV"
      # next if @plan[@headers["market_coverage"]].downcase == INDIVIDUAL
      next if @plan[@headers["metal_level"]].downcase == CATASTROPHIC
      next if cost_share_variance_params[:csr_variation_type] == "00"
      find_or_build_qhp
    end
  end

  def find_qhp
    @qhp = Products::Qhp.where(active_year: qhp_params[:active_year],
      standard_component_id: qhp_params[:standard_component_id]).first
  end

  def find_qcsv
    @csv = Products::QhpCostShareVariance.find_qhp_cost_share_variances(
      [assign_params[:hios_id]], assign_params[:active_year], assign_params[:coverage_kind]
    )
  end

  def find_or_build_qhp
    find_qhp
    @qhp = Products::Qhp.new(qhp_params) if !@qhp.present?
    find_qcsv
    if !@csv.present?
      csv = @qhp.qhp_cost_share_variances.build(cost_share_variance_params)
      csv.qhp_maximum_out_of_pockets.build(moop_params)
      csv.build_qhp_deductable(deductible_params)
      if @qhp.valid?
        @qhp.save!
        assign_params
        build_and_save_plan
      else
        puts "unable to save qhp because of errors: #{@qhp.errors.full_messages}"
      end
    end
  end

  def build_and_save_plan
    plan = Plan.where(active_year: assign_params[:active_year],
          hios_id: /#{assign_params[:hios_id]}/,
          hios_base_id: /#{assign_params[:hios_id].split('-').first}/,
          csr_variant_id: assign_params[:csr_variant_id]).to_a
    if plan.present?
      "Plan already present"
    else
      plan = Plan.new(assign_params)
      plan.save!
    end
  end

  def moop_params
    if qhp_params[:dental_plan_only_ind].downcase == "yes"
      moop_params_dental
    else
      moop_params_health
    end
  end

  def deductible_params
    if qhp_params[:dental_plan_only_ind].downcase == "yes"
      deductible_params_dental
    else
      deductible_params_health
    end
  end

  def cost_share_variance_params
    {
      hios_plan_and_variant_id: @plan[@headers["plan_id"]],
      plan_marketing_name: @plan[@headers["plan_marketing_name"]],
      metal_level: parse_metal_level,
      csr_variation_type: @plan[@headers["plan_id"]].split("-").last,

      issuer_actuarial_value: @plan[@headers["issuer_actuarial_value"]],
      av_calculator_output_number: @plan[@headers["av_calculator_output_number"]],

      medical_and_drug_deductibles_integrated: @plan[@headers["medical_drug_deductibles_integrated"]],
      medical_and_drug_max_out_of_pocket_integrated: @plan[@headers["medical_drug_maximum_outof_pocket_integrated"]],
      multiple_provider_tiers: @plan[@headers["multiple_in_network_tiers"]],
      first_tier_utilization: @plan[@headers["first_tier_utilization"]],
      second_tier_utilization: @plan[@headers["second_tier_utilization"]],

      having_baby_deductible: @plan[@headers["sbc_havinga_baby_deductible"]],
      having_baby_co_payment: @plan[@headers["sbc_havinga_baby_copayment"]],
      having_baby_co_insurance: @plan[@headers["sbc_havinga_baby_coinsurance"]],
      having_baby_limit: @plan[@headers["sbc_havinga_baby_limit"]],
      having_diabetes_deductible: @plan[@headers["sbc_having_diabetes_deductible"]],
      having_diabetes_copay: @plan[@headers["sbc_having_diabetes_copayment"]],
      having_diabetes_co_insurance: @plan[@headers["sbc_having_diabetes_coinsurance"]],
      having_diabetes_limit: @plan[@headers["sbc_having_diabetes_limit"]]
    }
  end

  def deductible_params_health
    {
      deductible_type: "Combined Medical and Drug EHB Deductible",
      in_network_tier_1_individual: @plan[@headers["tehb_ded_inn_tier1_individual"]],
      coinsurance_in_network_tier_1: @plan[@headers["tehb_ded_inn_tier1_coinsurance"]],
      in_network_tier_two_individual: @plan[@headers["tehb_ded_inn_tier2_individual"]],
      coinsurance_in_network_tier_2: @plan[@headers["tehb_ded_inn_tier2_coinsurance"]],
      out_of_network_individual: @plan[@headers["tehb_ded_out_of_net_individual"]],
      combined_in_or_out_network_individual: @plan[@headers["tehb_ded_comb_inn_oon_individual"]],

      # in_network_tier_1_family: @plan[@headers["tehb_ded_inn_tier1_family"]],
      # in_network_tier_two_family: @plan[@headers["tehb_ded_inn_tier2_family"]],
      # out_of_network_family: @plan[@headers["tehb_ded_out_of_net_family"]],
      # combined_in_or_out_network_family: @plan[@headers["tehb_ded_comb_inn_oon_family"]],

      in_network_tier_1_family: @plan[@headers["tehb_ded_inn_tier1_family_per_person"]],
      in_network_tier_two_family: @plan[@headers["tehb_ded_inn_tier2_family_per_person"]],
      out_of_network_family: @plan[@headers["tehb_ded_out_of_net_family_per_person"]],
      combined_in_or_out_network_family: @plan[@headers["tehb_ded_comb_inn_oon_family_per_person"]],
    }
  end

  def deductible_params_dental
    {
      deductible_type: "Medical EHB Deductible",
      in_network_tier_1_individual: @plan[@headers["mehb_ded_inn_tier1_individual"]],
      coinsurance_in_network_tier_1: @plan[@headers["mehb_ded_inn_tier1_coinsurance"]],
      in_network_tier_two_individual: @plan[@headers["mehb_ded_inn_tier2_individual"]],
      coinsurance_in_network_tier_2: @plan[@headers["mehb_ded_inn_tier2_coinsurance"]],
      out_of_network_individual: @plan[@headers["mehb_ded_out_of_net_individual"]],
      combined_in_or_out_network_individual: @plan[@headers["mehb_ded_comb_inn_oon_individual"]],

      # in_network_tier_1_family: @plan[@headers["mehb_ded_inn_tier1_family"]],
      # in_network_tier_two_family: @plan[@headers["mehb_ded_inn_tier2_family"]],
      # out_of_network_family: @plan[@headers["mehb_ded_out_of_net_family"]],
      # combined_in_or_out_network_family: @plan[@headers["mehb_ded_comb_inn_oon_family"]],

      in_network_tier_1_family: @plan[@headers["mehb_ded_inn_tier1_family_per_person"]],
      in_network_tier_two_family: @plan[@headers["mehb_ded_inn_tier2_family_per_person"]],
      out_of_network_family: @plan[@headers["mehb_ded_out_of_net_family_per_person"]],
      combined_in_or_out_network_family: @plan[@headers["mehb_ded_comb_inn_oon_family_per_person"]],
    }
  end

  def moop_params_dental
    {
      name: "Maximum Out of Pocket for Medical EHB Benefits",
      in_network_tier_1_individual_amount: @plan[@headers["mehb_inn_tier1_individual_moop"]],
      in_network_tier_2_individual_amount: @plan[@headers["mehb_inn_tier2_individual_moop"]],
      out_of_network_individual_amount: @plan[@headers["mehb_out_of_net_individual_moop"]],
      combined_in_out_network_individual_amount: @plan[@headers["mehb_comb_inn_oon_individual_moop"]],

      # in_network_tier_1_family_amount: @plan[@headers["mehb_inn_tier1_family_moop"]],
      # in_network_tier_2_family_amount: @plan[@headers["mehb_inn_tier2_family_moop"]],
      # out_of_network_family_amount: @plan[@headers["mehb_out_of_net_family_moop"]],
      # combined_in_out_network_family_amount: @plan[@headers["mehb_comb_inn_oon_family_moop"]],

      in_network_tier_1_family_amount: @plan[@headers["mehb_inn_tier1_family_per_person_moop"]],
      in_network_tier_2_family_amount: @plan[@headers["mehb_inn_tier2_family_per_group_moop"]],
      out_of_network_family_amount: @plan[@headers["mehb_out_of_net_family_per_person_moop"]],
      combined_in_out_network_family_amount: @plan[@headers["mehb_comb_inn_oon_family_per_person_moop"]],
    }
  end

  def moop_params_health
    {
      name: "Maximum Out of Pocket for Medical and Drug EHB Benefits (Total)",
      in_network_tier_1_individual_amount: @plan[@headers["tehb_inn_tier1_individual_moop"]],
      in_network_tier_2_individual_amount: @plan[@headers["tehb_inn_tier2_individual_moop"]],
      out_of_network_individual_amount: @plan[@headers["tehb_out_of_net_individual_moop"]],
      combined_in_out_network_individual_amount: @plan[@headers["tehb_comb_inn_oon_individual_moop"]],

      # in_network_tier_1_family_amount: @plan[@headers["tehb_inn_tier1_family_moop"]],
      # in_network_tier_2_family_amount: @plan[@headers["tehb_inn_tier2_family_moop"]],
      # out_of_network_family_amount: @plan[@headers["tehb_out_of_net_family_moop"]],
      # combined_in_out_network_family_amount: @plan[@headers["tehb_comb_inn_oon_family_moop"]]

      in_network_tier_1_family_amount: @plan[@headers["tehb_inn_tier1_family_per_person_moop"]],
      in_network_tier_2_family_amount: @plan[@headers["tehb_inn_tier2_family_per_person_moop"]],
      out_of_network_family_amount: @plan[@headers["tehb_out_of_net_family_per_group_moop"]],
      combined_in_out_network_family_amount: @plan[@headers["tehb_comb_inn_oon_family_per_person_moop"]],
    }
  end

  def qhp_params
    {
      template_version: @plan[@headers["version_num"]],
      issuer_id: @plan[@headers["issuer_id2"]],
      state_postal_code: @plan[@headers["state_code"]],
      # market_coverage: @plan[@headers["market_coverage"]] == SHOP_SMALL_GROUP ? SHOP : INDIVIDUAL,
      market_coverage: SHOP,
      dental_plan_only_ind: @plan[@headers["dental_only_plan"]],
      tin: @plan[@headers["tin"]],
      standard_component_id: @plan[@headers["standard_component_id"]],
      plan_marketing_name: @plan[@headers["plan_marketing_name"]],
      hios_product_id: @plan[@headers["hios_product_id"]],
      hpid: @plan[@headers["hpid"]],
      network_id: @plan[@headers["network_id"]],
      service_area_id: @plan[@headers["service_area_id"]],
      formulary_id: @plan[@headers["formulary_id"]],
      is_new_plan: @plan[@headers["is_new_plan"]],
      plan_type: @plan[@headers["plan_type"]],
      metal_level: @plan[@headers["metal_level"]],
      unique_plan_design: @plan[@headers["unique_plan_design"]],
      qhp_or_non_qhp: @plan[@headers["qhp_non_qhp_type_id"]],
      insurance_plan_pregnancy_notice_req_ind: @plan[@headers["is_notice_required_for_pregnancy"]],
      is_specialist_referral_required: @plan[@headers["is_referral_required_for_specialist"]],
      health_care_specialist_referral_type: @plan[@headers["specialist_requiring_referral"]],
      insurance_plan_benefit_exclusion_text: @plan[@headers["plan_level_exclusions"]],
      indian_plan_variation: @plan[@headers["indian_plan_variation_estimated_advanced_payment_amount_per_enrollee"]],
      ehb_percent_premium: @plan[@headers["business_year"]] == "2015" ? @plan[@headers["ehb_percent_premium_s4"]] : @plan[@headers["ehb_percent_total_premium"]],
      hsa_eligibility: @plan[@headers["is_hsa_eligible"]],
      employer_hsa_hra_contribution_indicator: @plan[@headers["hsa_or_hra_employer_contribution"]],
      emp_contribution_amount_for_hsa_or_hra: @plan[@headers["hsa_or_hra_employer_contribution_amount"]] || 0,
      child_only_offering: @plan[@headers["child_only_offering"]],
      child_only_plan_id: @plan[@headers["child_only_plan_id"]],
      is_wellness_program_offered: @plan[@headers["wellness_program_offered"]],
      is_disease_mgmt_programs_offered: @plan[@headers["disease_management_programs_offered"]],
      ehb_apportionment_for_pediatric_dental: @plan[@headers["ehb_pediatric_dental_apportionment_quantity"]],
      guaranteed_vs_estimated_rate: @plan[@headers["is_guaranteed_rate"]],
      maximum_coinsurance_for_specialty_drugs: @plan[@headers["specialty_drug_maximum_coinsurance"]],
      max_num_days_for_charging_inpatient_copay: @plan[@headers["inpatient_copayment_maximum_days"]],
      begin_primary_care_cost_sharing_after_set_number_visits: @plan[@headers["begin_primary_care_cost_sharing_after_number_of_visits"]],
      begin_primary_care_deductible_or_coinsurance_after_set_number_copays: @plan[@headers["begin_primary_care_deductible_coinsurance_after_number_of_copays"]],
      plan_effective_date: @plan[@headers["plan_effictive_date"]],
      plan_expiration_date: @plan[@headers["plan_expiration_date"]],
      active_year: @plan[@headers["business_year"]],
      out_of_country_coverage: @plan[@headers["out_of_country_coverage"]],
      out_of_country_coverage_description: @plan[@headers["out_of_country_coverage_description"]],
      out_of_service_area_coverage: @plan[@headers["out_of_service_area_coverage"]],
      out_of_service_area_coverage_description: @plan[@headers["out_of_service_area_coverage_description"]],
      national_network: @plan[@headers["national_network"]],
      summary_benefit_and_coverage_url: @plan[@headers["url_for_summaryof_benefits_coverage"]],
      enrollment_payment_url: @plan[@headers["url_for_enrollment_payment"]],
      plan_brochure: @plan[@headers["plan_brochure"]],
    }
  end

  def assign_params
    nationwide, dc_in_network = parse_nation_wide_and_dc_in_network
    {
      active_year: @plan[@headers["business_year"]],
      # market: #@plan[@headers["market_coverage"]] == SHOP_SMALL_GROUP ? SHOP : INDIVIDUAL,
      market: SHOP,
      coverage_kind: @plan[@headers["dental_only_plan"]].downcase == "no" ? HEALTH : DENTAL,
      carrier_profile_id: get_carrier_profile_id,
      metal_level: parse_metal_level,
      hios_id: @metal_level == DENTAL ? @plan[@headers["standard_component_id"]] : @plan[@headers["plan_id"]],
      hios_base_id: @plan[@headers["standard_component_id"]],
      csr_variant_id: @metal_level == DENTAL ? "" : @plan[@headers["plan_id"]].split("-").last,
      name: @plan[@headers["plan_marketing_name"]],
      # ehb: @plan[@headers["ehb_percent_premium_s4"]],
      ehb: @plan[@headers["ehb_percent_total_premium"]],
      nationwide: nationwide,
      dc_in_network: dc_in_network,
      plan_type: @plan[@headers["plan_type"]].downcase,
      dental_level: @plan[@headers["dental_only_plan"]].downcase == "yes" ? @plan[@headers["metal_level"]].downcase : ""
    }
  end

  def get_carrier_profile_id
    CarrierProfile.find_by_legal_name(get_carrier_name)
  end

  def get_carrier_name
    plan_to_carrier_name_mapping_2016[@plan[@headers["plan_marketing_name"]]]
  end

  # def get_carrier_profile_id
  #   org = Organization.where(
  #     "carrier_profile.network_id" => @plan[@headers["network_id"]],
  #     "carrier_profile.issuer_id" => @plan[@headers["issuer_id"]]
  #     ).first
  #   org.carrier_profile.id
  # end

  def parse_nation_wide_and_dc_in_network
    if @plan[@headers["national_network"]].downcase.strip == "yes"
      ["true", "false"]
    else
      ["false", "true"]
    end
  end

  def parse_metal_level
    @metal_level = if ["high","low"].include?(@plan[@headers["metal_level"]].downcase)
      DENTAL
    else
      @plan[@headers["metal_level"]].downcase
    end
  end

  def plan_to_carrier_name_mapping_2016
    {
      "Anthem Blue Cross and Blue Shield  Silver DirectAccess, a Multi-State Plan" => "Anthem",
      "Anthem Blue Cross and Blue Shield Gold DirectAccess, a Multi-State Plan" => "Anthem",
      "Anthem Bronze Pathway X HMO 0 for HSA" => "Anthem",
      "Anthem Bronze Pathway X HMO 4950 50" => "Anthem",
      "Anthem Bronze Pathway X HMO 5000 40" => "Anthem",
      "Anthem Bronze Pathway X HMO 5000/30%/6850 Plus" => "Anthem",
      "Anthem Bronze Pathway X HMO 5950 35" => "Anthem",
      "Anthem Bronze Pathway X HMO 6150 20" => "Anthem",
      "Anthem Bronze Pathway X PPO 20 for HSA" => "Anthem",
      "Anthem Bronze Pathway X PPO 4500 20" => "Anthem",
      "Anthem Bronze Pathway X PPO 5200 20" => "Anthem",
      "Anthem Bronze Pathway X PPO 6200 30" => "Anthem",
      "Anthem Gold Pathway X HMO 1000 20" => "Anthem",
      "Anthem Gold Pathway X HMO 1000/10%/5500 Plus" => "Anthem",
      "Anthem Gold Pathway X HMO 1450 25" => "Anthem",
      "Anthem Gold Pathway X HMO 1800 50" => "Anthem",
      "Anthem Gold Pathway X PPO 1500 10" => "Anthem",
      "Anthem Silver Pathway X HMO 2000 40" => "Anthem",
      "Anthem Silver Pathway X HMO 2250 20" => "Anthem",
      "Anthem Silver Pathway X HMO 2250 30" => "Anthem",
      "Anthem Silver Pathway X HMO 2350 15" => "Anthem",
      "Anthem Silver Pathway X HMO 2500 40" => "Anthem",
      "Anthem Silver Pathway X HMO 3000/20%/6000 Plus" => "Anthem",
      "Anthem Silver Pathway X PPO 2250 20" => "Anthem",
      "Anthem Silver Pathway X PPO 2500 15" => "Anthem",
      "Anthem Silver Pathway X PPO 2750 10" => "Anthem",
      "Anthem Silver Pathway X PPO 3500 0" => "Anthem",
      "Anthem Silver Pathway X PPO 4000 15" => "Anthem",
      "Anthem Dental Family" => "Anthem Dental",
      "Anthem Dental Family Enhanced" => "Anthem Dental",
      "Anthem Dental Pediatric" => "Anthem Dental",
      "BESTDental Choice - H" => "BestLife",
      "BESTDental Choice - L" => "BestLife",
      "BESTDental Premium" => "BestLife",
      "BESTDental Standard - H" => "BestLife",
      "BESTDental Standard - L" => "BestLife",
      "BESTDental Value" => "BestLife",
      "BESTOne Advantage Gold" => "BestLife",
      "BESTOne Basic Silver" => "BestLife",
      "BESTOne Plus Gold" => "BestLife",
      "BESTOne Plus Silver" => "BestLife",
      "Delta Dental PPO Basic Plan for Families" => "Delta Dental",
      "Delta Dental PPO Basic Plan for Families for Small Businesses" => "Delta Dental",
      "Delta Dental PPO Preferred Plan for Families" => "Delta Dental",
      "Delta Dental PPO Preferred Plan for Families for Small Businesses" => "Delta Dental",
      "DeltaCare USA Basic Plan for Families" => "Delta Dental",
      "DeltaCare USA Basic Plan for Families for Small Businesses" => "Delta Dental",
      "DeltaCare USA Preferred Plan for Families" => "Delta Dental",
      "DeltaCare USA Preferred Plan for Families for Small Businesses" => "Delta Dental",
      "Dentegra Dental PPO Family Basic Plan" => "Dentegra",
      "Dentegra Dental PPO Family Preferred Plan" => "Dentegra",
      "Dentegra Dental PPO for Small Businesses Family Basic Plan" => "Dentegra",
      "Dentegra Dental PPO for Small Businesses Family Preferred Plan" => "Dentegra",
      "Guardian Family Advantage" => "Guardian",
      "Guardian Family Essentials" => "Guardian",
      "MyHPN Bronze 10" => "Health Plan of Nevada",
      "MyHPN Bronze 7" => "Health Plan of Nevada",
      "MyHPN Bronze 8" => "Health Plan of Nevada",
      "MyHPN Bronze 9" => "Health Plan of Nevada",
      "MyHPN Catastrophic" => "Health Plan of Nevada",
      "MyHPN Gold 1" => "Health Plan of Nevada",
      "MyHPN Gold 2" => "Health Plan of Nevada",
      "MyHPN Gold 3" => "Health Plan of Nevada",
      "MyHPN Gold 4" => "Health Plan of Nevada",
      "MyHPN Gold 5" => "Health Plan of Nevada",
      "MyHPN Platinum 1" => "Health Plan of Nevada",
      "MyHPN Silver 1.1" => "Health Plan of Nevada",
      "MyHPN Silver 3.1" => "Health Plan of Nevada",
      "MyHPN Silver 4.1" => "Health Plan of Nevada",
      "MyHPN Silver 5" => "Health Plan of Nevada",
      "MyHPN Silver 6/Medicaid Transition Plan" => "Health Plan of Nevada",
      "NDB Nevada Kids + Adult" => "Nevada Dental Benefits",
      "NDB Nevada Kids Gold" => "Nevada Dental Benefits",
      "NDB Nevada Kids Silver" => "Nevada Dental Benefits",
      "Prominence Health Plan Bronze 4 Health Care Partners" => "Prominence",
      "Prominence Health Plan Bronze 4 Premier" => "Prominence",
      "Prominence Health Plan Bronze 4 WellHealth" => "Prominence",
      "Prominence Health Plan Bronze 5 Health Care Partners" => "Prominence",
      "Prominence Health Plan Bronze 5 Premier" => "Prominence",
      "Prominence Health Plan Bronze 5 WellHealth" => "Prominence",
      "Prominence Health Plan Bronze 6 Premier" => "Prominence",
      "Prominence Health Plan Gold 1 ChoicePlus" => "Prominence",
      "Prominence Health Plan Gold 1 Health Care Partners" => "Prominence",
      "Prominence Health Plan Gold 1 Premier" => "Prominence",
      "Prominence Health Plan Gold 1 WellHealth" => "Prominence",
      "Prominence Health Plan HSA 1 Premier" => "Prominence",
      "Prominence Health Plan Silver 10 Health Care Partners" => "Prominence",
      "Prominence Health Plan Silver 10 Premier" => "Prominence",
      "Prominence Health Plan Silver 10 WellHealth" => "Prominence",
      "Prominence Health Plan Silver 20 ChoicePlus" => "Prominence",
      "Prominence Health Plan Silver 20 Premier" => "Prominence",
      "Prominence Health Plan Silver 30 Premier" => "Prominence",
      "Prominence Health Plan Silver 50 Health Care Partners" => "Prominence",
      "Prominence Health Plan Silver 50 Premier" => "Prominence",
      "Prominence Health Plan Silver 50 WellHealth" => "Prominence"
    }
  end

  def plan_to_carrier_name_mapping
    {
      "BEST Dental Choice-H" => "BestLife",
      "BEST Dental Choice-L" => "BestLife",
      "BEST Dental Premium" => "BestLife",
      "BEST Dental Standard-H" => "BestLife",
      "BEST Dental Standard-L" => "BestLife",
      "BEST Dental Value" => "BestLife",
      "Connected/Conectado Gold" => "Nevada Health CO-OP",
      "Connected/Conectado Platinum" => "Nevada Health CO-OP",
      "Connected/Conectado Silver" => "Nevada Health CO-OP",
      "Delta Dental PPO Basic Plan for Families for Small Businesses" => "Delta Dental",
      "Delta Dental PPO Preferred Plan for Families for Small Businesses" => "Delta Dental",
      "DeltaCare USA Basic Plan for Families for Small Businesses" => "Delta Dental",
      "DeltaCare USA Preferred Plan for Families for Small Businesses" => "Delta Dental",
      "Dentegra Dental PPO for Small Businesses Family Basic Plan" => "Dentegra",
      "Dentegra Dental PPO for Small Businesses Family Preferred Plan" => "Dentegra",
      "Family DHMO Plan with EHB" => "Premier Life",
      "Frontier Simple/F?cil Bronze HSA" => "Nevada Health CO-OP",
      "Frontier Simple/F?cil Gold" => "Nevada Health CO-OP",
      "Frontier Simple/F?cil Platinum" => "Nevada Health CO-OP",
      "Frontier Simple/F?cil Silver" => "Nevada Health CO-OP",
      "Guardian Family Advantage" => "Guardian",
      "Guardian Family Essentials" => "Guardian",
      "LIBERTY Dental Plan NV Pediatric High with Adult Option" => "Liberty",
      "LIBERTY Dental Plan NV Pediatric Low with Adult Option" => "Liberty",
      "Northern Simple/F?cil Bronze HSA" => "Nevada Health CO-OP",
      "Northern Simple/F?cil Gold" => "Nevada Health CO-OP",
      "Northern Simple/F?cil Platinum" => "Nevada Health CO-OP",
      "Northern Simple/F?cil Silver" => "Nevada Health CO-OP",
      "Southern Simple/F?cil Bronze" => "Nevada Health CO-OP",
      "Southern Simple/F?cil Gold" => "Nevada Health CO-OP",
      "Southern Simple/F?cil Platinum" => "Nevada Health CO-OP",
      "Southern Simple/F?cil Silver" => "Nevada Health CO-OP",
      "Southern Simple/Facil Bronze HSA" => "Nevada Health CO-OP",
      "Southern Simple/Facil Gold HSA" => "Nevada Health CO-OP",
      "Southern Star/Estrella Gold" => "Nevada Health CO-OP",
      "Southern Star/Estrella Platinum" => "Nevada Health CO-OP",
      "Southern Star/Estrella Silver" => "Nevada Health CO-OP",
      "Union Star/Estrella Gold" => "Nevada Health CO-OP",
      "Union Star/Estrella Platinum" => "Nevada Health CO-OP",
      "Union Star/Estrella Silver" => "Nevada Health CO-OP",
      "VIP Gold" => "Nevada Health CO-OP",
      "VIP Platinum" => "Nevada Health CO-OP",
      "VIP Silver" => "Nevada Health CO-OP",
    }
  end

# 2016 Shop plan names
  # def plan_to_carrier_name_mapping_2016
  #   {
  #     "Anthem Bronze Pathway X HMO 5000/30%/6850 Plus" => "Anthem", # Shop Health
  #     "Anthem Silver Pathway X HMO 3000/20%/6000 Plus" => "Anthem", # Shop Health
  #     "Anthem Gold Pathway X HMO 1000/10%/5500 Plus" => "Anthem", # Shop Health
  #     "BESTDental Premium" => "BestLife", # Shop Dental
  #     "BESTDental Standard - H" => "BestLife", # Shop Dental
  #     "BESTDental Choice - H" => "BestLife", # Shop Dental
  #     "BESTDental Standard - L" => "BestLife", # Shop Dental
  #     "BESTDental Choice - L" => "BestLife", # Shop Dental
  #     "BESTDental Value" => "BestLife", # Shop Dental
  #     "Delta Dental PPO Preferred Plan for Families for Small Businesses" => "Delta Dental", # Shop Dental
  #     "Delta Dental PPO Basic Plan for Families for Small Businesses" => "Delta Dental", # Shop Dental
  #     "DeltaCare USA Preferred Plan for Families for Small Businesses" => "Delta Dental", # Shop Dental
  #     "DeltaCare USA Basic Plan for Families for Small Businesses" => "Delta Dental", # Shop Dental
  #     "Dentegra Dental PPO for Small Businesses Family Preferred Plan" => "Dentegra", # Shop Dental
  #     "Dentegra Dental PPO for Small Businesses Family Basic Plan" => "Dentegra", # Shop Dental
  #     "Guardian Family Advantage" => "Guardian", # Shop Dental
  #     "Guardian Family Essentials" => "Guardian", # Shop Dental
  #   }
  # end

end
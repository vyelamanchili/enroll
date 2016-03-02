class BenefitCostSharingBuilder < CmsParentBuilder

  def run
    iterate_plans_hash
  end

  def iterate_plans_hash
    (@first_row..@last_row).each do |row_number|
      @plan = @data.row(row_number)
      build_qhp_benefits_and_service_visits
    end
  end

  def build_qhp_benefits_and_service_visits
    find_qhp_cost_share_variance
    if @qcsv.present?
      @qhp.qhp_benefits.build(benefit_params)
      @qcsv.qhp_service_visits.build(service_visit_params)
      if @qhp.valid?
        @qhp.save
      end
    end
  end

  def find_qhp_cost_share_variance
    @qhp = Products::Qhp.where(params).first
    @qcsv = @qhp.qhp_cost_share_variances.where(hios_plan_and_variant_id: @plan[@headers["plan_id"]]).first
  end

  def service_visit_params
    {
      visit_type: @plan[@headers["benefit_name"]],
      copay_in_network_tier_1: @plan[@headers["copay_inn_tier1"]],
      copay_in_network_tier_2: @plan[@headers["copay_inn_tier2"]],
      copay_out_of_network: @plan[@headers["copay_outof_net"]],
      co_insurance_in_network_tier_1: @plan[@headers["coins_inn_tier1"]],
      co_insurance_in_network_tier_2: @plan[@headers["coins_inn_tier2"]],
      co_insurance_out_of_network: @plan[@headers["coins_outof_net"]],
    }
  end

  def benefit_params
    {
      benefit_type_code: @plan[@headers["benefit_name"]],
      is_ehb: @plan[@headers["is_ehb"]],
      is_state_mandate: @plan[@headers["is_state_mandate"]],
      is_benefit_covered: @plan[@headers["is_covered"]],
      service_limit: @plan[@headers["quant_limit_on_svc"]],
      quantity_limit: @plan[@headers["limit_qty"]],
      unit_limit: @plan[@headers["limit_unit"]],
      minimum_stay: @plan[@headers["minimum_stay"]],
      exclusion: @plan[@headers["exclusions"]],
      explanation: @plan[@headers["explanation"]],
      ehb_variance_reason: @plan[@headers["ehb_var_reason"]],
      subject_to_deductible_tier_1: @plan[@headers["is_subj_to_ded_tier1"]],
      subject_to_deductible_tier_2: @plan[@headers["is_subj_to_ded_tier2"]],
      excluded_in_network_moop: @plan[@headers["is_excl_from_inn_moop"]],
      excluded_out_of_network_moop: @plan[@headers["is_excl_from_oon_moop"]],
    }
  end

  def params
    {
      standard_component_id: @plan[@headers["standard_component_id"]],
      active_year: @plan[@headers["business_year"]]
    }
  end

end
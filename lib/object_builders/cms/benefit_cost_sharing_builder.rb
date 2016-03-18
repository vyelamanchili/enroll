require 'csv'
class BenefitCostSharingBuilder

  def initialize(file, state_code)
    @state_code = state_code
    @file = file
  end

  def run
    CSV.foreach(@file,
                :headers => true,
                :header_converters => lambda { |h| h.underscore.to_sym }) do |row|
      next if row[:state_code] != @state_code
      @plan = row
      build_qhp_benefits_and_service_visits
    end
  end

  def build_qhp_benefits_and_service_visits
    find_qhp_cost_share_variance
    if @qcsv.present?
      @qhp.qhp_benefits.build(benefit_params) if @plan[:plan_id].split("-").last == "01"
      @qcsv.qhp_service_visits.build(service_visit_params)
      @qhp.save
    end
  end

  def find_qhp_cost_share_variance
    # @qhp = Rails.cache.fetch("qhp-import-#{@plan[:business_year].squish}-hios-id-#{@plan[:plan_id]}", expires_in: 5.hour) do
    @qhp = Products::Qhp.where(params).first
    # end
    return @qcsv = nil if !@qhp.present?
    # @qcsv = Rails.cache.fetch("qcsv-import-#{@qhp.active_year}-hios-id-#{@plan[:plan_id]}", expires_in: 5.hour) do
    @qcsv = @qhp.qhp_cost_share_variances.where(hios_plan_and_variant_id: @plan[:plan_id]).first
    # end
  end

  def service_visit_params
    {
      visit_type: @plan[:benefit_name],
      copay_in_network_tier_1: @plan[:copay_inn_tier1],
      copay_in_network_tier_2: @plan[:copay_inn_tier2],
      copay_out_of_network: @plan[:copay_outof_net],
      co_insurance_in_network_tier_1: @plan[:coins_inn_tier1],
      co_insurance_in_network_tier_2: @plan[:coins_inn_tier2],
      co_insurance_out_of_network: @plan[:coins_outof_net],
    }
  end

  def benefit_params
    {
      benefit_type_code: @plan[:benefit_name],
      is_ehb: @plan[:is_ehb],
      is_state_mandate: @plan[:is_state_mandate],
      is_benefit_covered: @plan[:is_covered],
      service_limit: @plan[:quant_limit_on_svc],
      quantity_limit: @plan[:limit_qty],
      unit_limit: @plan[:limit_unit],
      minimum_stay: @plan[:minimum_stay],
      exclusion: @plan[:exclusions],
      explanation: @plan[:explanation],
      ehb_variance_reason: @plan[:ehb_var_reason],
      subject_to_deductible_tier_1: @plan[:is_subj_to_ded_tier1],
      subject_to_deductible_tier_2: @plan[:is_subj_to_ded_tier2],
      excluded_in_network_moop: @plan[:is_excl_from_inn_moop],
      excluded_out_of_network_moop: @plan[:is_excl_from_oon_moop],
    }
  end

  def params
    {
      standard_component_id: @plan[:standard_component_id],
      active_year: @plan[:business_year]
    }
  end

end
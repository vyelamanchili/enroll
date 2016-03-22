class NetworkBuilder < CmsParentBuilder

  def run
    @fein_counter = 1
    iterate_network_hash
  end

  def iterate_network_hash
    (@first_row..@last_row).each do |row_number|
      @network = @data.row(row_number)
      next if @network[@headers["state_code"]] != @state_code
      # next if @network[@headers["market_coverage"]].downcase == "individual"
      # next if network_present?
      next if network_name_present?
      build_and_save_organization
    end
  end

  def network_name_present?
    carrier = CarrierProfile.find_by_legal_name(get_legal_name)
    carrier.present? ? true : false
  end

  def network_present?
    org = Organization.where(
      "carrier_profile.network_id" => @network[@headers["network_id"]],
      "carrier_profile.issuer_id" => @network[@headers["issuer_id"]]
      )
    org.size > 0 ? true : false
  end

  def build_and_save_organization
    @organization = Organization.new(office_locations: [hbx_office_params], fein: generate_fein, legal_name: get_legal_name)
    # @organization = Organization.new(office_locations: [hbx_office_params], fein: generate_fein, legal_name: @network[@headers["network_name"]])
    @organization.build_carrier_profile(carrier_profile_params)
    @organization.save
  end

  def get_legal_name
    network_mapping_params[@network[@headers["network_name"]]]
  end

  def generate_fein
    @fein_counter += 1
    fein = sprintf '%09d', @fein_counter
    organization = Organization.where("fein" => fein)
    organization.size > 0 ?  generate_fein : fein
  end

  def carrier_profile_params
   {
      network_id: @network[@headers["network_id"]],
      issuer_id: @network[@headers["issuer_id"]],
      issuer_state: @network[@headers["state_code"]],
      market_coverage: @network[@headers["market_coverage"]],
      # dental_only_plan: @network[@headers["dental_only"]],
      dental_only_plan: @network[@headers["dental_only_plan"]],

    }
  end

  def hbx_office_params
    OfficeLocation.new(
      is_primary: true,
      address: {kind: "work", address_1: "address_placeholder", address_2: "609 H St, Room 415", city: "Washington", state: "DC", zip: "20002" },
      phone: {kind: "main", area_code: "202", number: "555-1212"}
    )
  end

  def network_mapping_params
    # {
    #   "Access Dental" => "Premier Life",
    #   "BEST Life PPO Network" => "BestLife",
    #   "Connected/Conectado" => "Nevada Health CO-OP",
    #   "Delta Dental PPO" => "Delta Dental",
    #   "DeltaCare USA DHMO" => "Delta Dental",
    #   "DentalGuard Preferred" => "Guardian",
    #   "Dentegra Dental PPO" => "Dentegra",
    #   "Frontier Simple/F?cil" => "Nevada Health CO-OP",
    #   "HSA" => "Nevada Health CO-OP",
    #   "Health Link EPO" => "Liberty",
    #   "Northern Simple/F?cil" => "Nevada Health CO-OP",
    #   "Southern Simple/F?cil" => "Nevada Health CO-OP",
    #   "Star/Estrella" => "Nevada Health CO-OP",
    #   "VIP" => "Nevada Health CO-OP",
    # }
    {
      "Dental Prime" => "Anthem Dental",
      "BEST Life Nationwide" => "BestLife",
      "Delta Dental PPO" => "Delta Dental",
      "DeltaCare DHMO" => "Delta Dental",
      "DentalGuard Preferred" => "Guardian",
      "Dentegra Dental PPO" => "Dentegra",
      "HPN HMO - On Exchange" => "Health Plan of Nevada",
      "NDB Network - SA1MC" => "Nevada Dental Benefits",
      "NDB Network - SA2MC" => "Nevada Dental Benefits",
      "Pathway X - HMO and Dental Prime" => "Anthem",
      "Pathway X - PPO and Dental Prime" => "Anthem",
      "Premier HMO North Network" => "Prominence", # Indiv
      "Prominence HMO Network (HCP)" => "Prominence", # Indiv
      "Prominence HMO WellHealth Network" => "Prominence", # Indiv
      "Prominence HealthFirst HMO Network (ChoicePlus)" => "Prominence", #Indiv
      # "Prominence HealthFirst HMO/POS Network" => "Prominence",
      # "Network Savings 1" => "Assurant Health",
    }
  end
end

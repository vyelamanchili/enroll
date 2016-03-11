class NetworkBuilder < CmsParentBuilder

  def run
    @fein_counter = 1
    iterate_network_hash
  end

  def iterate_network_hash
    (@first_row..@last_row).each do |row_number|
      @network = @data.row(row_number)
      next if network_present?
      build_and_save_organization
    end
  end

  def network_present?
    org = Organization.where(
      "carrier_profile.network_id" => @network[@headers["network_id"]],
      "carrier_profile.issuer_id" => @network[@headers["issuer_id"]]
      )
    org.size > 0 ? true : false
  end

  def build_and_save_organization
    @organization = Organization.new(office_locations: [hbx_office_params], fein: generate_fein, legal_name: @network[@headers["network_name"]])
    @organization.build_carrier_profile(carrier_profile_params)
    @organization.save
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
      dental_only_plan: @network[@headers["dental_only"]]

    }
  end

  def hbx_office_params
    OfficeLocation.new(
      is_primary: true,
      address: {kind: "work", address_1: "address_placeholder", address_2: "609 H St, Room 415", city: "Washington", state: "DC", zip: "20002" },
      phone: {kind: "main", area_code: "202", number: "555-1212"}
    )
  end
end
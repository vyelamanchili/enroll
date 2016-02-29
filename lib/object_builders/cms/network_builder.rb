class NetworkBuilder

  def initialize(network_data)
    @network_data = network_data
    @last_row = @network_data.last_row
    @fein_counter = 1
  end

  def run
    iterate_network_hash
  end

  def iterate_network_hash
    assign_headers
    (2..@last_row).each do |row_number|
      @network = @network_data.row(row_number)
      next if network_present?
      build_and_save_organization
    end
  end

  def network_present?
    org = Organization.where(
      "carrier_profile.network_id" => @network[@headers["NetworkId"]],
      "carrier_profile.issuer_id" => @network[@headers["IssuerId"]]
      )
    org.size > 0 ? true : false
  end

  def assign_headers
    @headers = Hash.new
    @network_data.row(1).each_with_index {|header,i|
      @headers[header] = i
    }
    @headers
  end

  def build_and_save_organization
    @organization = Organization.new(office_locations: [hbx_office_params], fein: generate_fein, legal_name: @network[@headers["NetworkName"]])
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
    test = {
      network_id: @network[@headers["NetworkId"]],
      issuer_id: @network[@headers["IssuerId"]],
      issuer_state: @network[@headers["StateCode"]],
      market_coverage: @network[@headers["MarketCoverage"]],
      dental_only_plan: @network[@headers["DentalOnly"]]

    }
    test
  end

  def hbx_office_params
    OfficeLocation.new(
      is_primary: true,
      address: {kind: "work", address_1: "address_placeholder", address_2: "609 H St, Room 415", city: "Washington", state: "DC", zip: "20002" },
      phone: {kind: "main", area_code: "202", number: "555-1212"}
    )
  end
end
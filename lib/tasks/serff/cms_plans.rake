require Rails.root.join('lib', 'object_builders', "cms", 'cms_exchange_plans_builder.rb')
require Rails.root.join('lib', 'object_builders', "cms", 'network_builder.rb')
require Rails.root.join('lib', 'object_builders', "cms", 'plan_rate_builder.rb')

namespace :import do
  task :cms_exchange_plans => :environment do
    file = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2015", "Plan_Attributes_PUF.csv"))[0]

    puts "Importing cms exchange plans from #{file}..."
    if file.present?
      result = Roo::Spreadsheet.open(file)
      plan_data = CmsExchangePlansBuilder.new(result)
      plan_data.run
      # sheet_data = result.sheet(0)
      # last_row = sheet_data.last_row
      # # (26279..26286).each do |row_number|
      # (2..last_row).each do |row_number|
      #   row_info = sheet_data.row(row_number)
      #   binding.pry
        # hios_id, provider_directory_url, rx_formulary_url = row_info[2].squish, row_info[10], row_info[12]
        # plans = Plan.where(hios_id: /#{hios_id}/, active_year: 2016)
        # plans.each do |plan|
        #   plan.provider_directory_url = provider_directory_url
        #   plan.rx_formulary_url = rx_formulary_url.include?("http") ? rx_formulary_url : "http://#{rx_formulary_url}"
        #   plan.save
        # end
      # end
    end
  end

  task :network_information => :environment do
    file = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2015", "Network_PUF.csv"))[0]
    puts "Importing cms network information from #{file}..."
    if file.present?
      result = Roo::Spreadsheet.open(file)
      network_data = NetworkBuilder.new(result)
      network_data.run
    end
  end

  task :rate_information => :environment do
    file = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2015", "Rate_PUF_COPY.csv"))[0]
    puts "Importing rate information from #{file}..."
    if file.present?
      result = Roo::Spreadsheet.open(file)
      rate_data = PlanRateBuilder.new(result)
      rate_data.run
    end
  end
end

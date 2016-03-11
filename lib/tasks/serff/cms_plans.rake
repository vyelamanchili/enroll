require 'csv'
require Rails.root.join('lib', 'object_builders', "cms", 'cms_parent_builder.rb')
require Rails.root.join('lib', 'object_builders', "cms", 'cms_exchange_plans_builder.rb')
require Rails.root.join('lib', 'object_builders', "cms", 'network_builder.rb')
require Rails.root.join('lib', 'object_builders', "cms", 'plan_rate_builder.rb')
require Rails.root.join('lib', 'object_builders', "cms", 'benefit_cost_sharing_builder.rb')

namespace :import do

  task :network_data => :environment do
    file = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2015", "Network_PUF.csv"))[0]
    puts "Importing cms network information from #{file}..."
    if file.present?
      result = Roo::Spreadsheet.open(file)
      network_data = NetworkBuilder.new(result)
      network_data.run
    end
  end

  task :plan_data => :environment do
    file = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2015", "Plan_Attributes_PUF.csv"))[0]
    puts "Importing cms exchange plans from #{file}..."
    if file.present?
      result = Roo::Spreadsheet.open(file)
      plan_data = CmsExchangePlansBuilder.new(result)
      plan_data.run
    end

    puts "Assigning qhp_benefits and service visits to qhp."
    benefit_file = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2015", "Benefits_Cost_Sharing_PUF.csv"))[0]
    puts "#{benefit_file}"
    more_plan_data = BenefitCostSharingBuilder.new(benefit_file)
    more_plan_data.run

  end

  task :rate_data => :environment do
    file = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2015", "Rate_PUF.csv"))[0]
    puts "#{file}"

    plan_rate_data = PlanRateBuilder.new(file)
    plan_rate_data.run
  end

  # task :more_plan_data => :environment do
  #   file = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2015", "Benefits_Cost_Sharing_PUF.csv"))[0]
  #   puts "Importing rate information from #{file}..."
  #   if file.present?
  #     result = Roo::Spreadsheet.open(file)
  #     plan_data = BenefitCostSharingBuilder.new(result)
  #     plan_data.run
  #   end
  # end

  # task :rate_information => :environment do
  #   file = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2015", "Rate_PUF.csv"))[0]
  #   puts "Importing rate information from #{file}..."
  #   if file.present?
  #     result = Roo::Spreadsheet.open(file)
  #     rate_data = PlanRateBuilder.new(result)
  #     rate_data.run
  #   end
  # end

end

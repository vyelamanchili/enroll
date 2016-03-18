require 'csv'
require Rails.root.join('lib', 'object_builders', "cms", 'cms_parent_builder.rb')
require Rails.root.join('lib', 'object_builders', "cms", 'cms_exchange_plans_builder.rb')
require Rails.root.join('lib', 'object_builders', "cms", 'network_builder.rb')
require Rails.root.join('lib', 'object_builders', "cms", 'plan_rate_builder.rb')
require Rails.root.join('lib', 'object_builders', "cms", 'benefit_cost_sharing_builder.rb')

namespace :import do

  task :network_data, [:state_code] => :environment do |task, args|
    network_files = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2016", "**" ,"Network_PUF_NV.csv"))
    network_files.each do |network_file|
      puts "Importing cms network information from #{network_file}..."
      if network_file.present?
        result = Roo::Spreadsheet.open(network_file)
        network_data = NetworkBuilder.new(result, args[:state_code])
        network_data.run
      end
      puts "Importing cms network information complete"
    end
  end

  task :plan_data, [:state_code] => :environment do |task, args|
    plan_files = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2016", "**", "Plan_Attributes_PUF_NV.csv"))
    plan_files.each do |plan_file|
      puts "Importing cms exchange plans from #{plan_file}..."
      if plan_file.present?
        result = Roo::Spreadsheet.open(plan_file)
        plan_data = CmsExchangePlansBuilder.new(result, args[:state_code])
        plan_data.run
      end
      puts "Importing plans complete"
    end
  end

  task :more_plan_data, [:state_code] => :environment do |task, args|
    puts "Assigning qhp_benefits and service visits to qhp."
    benefit_files = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2016", "**" ,"Benefits_Cost_Sharing_PUF_NV.csv"))
    benefit_files.each do |benefit_file|
      puts "Importing benefits file  : #{benefit_file}"
      more_plan_data = BenefitCostSharingBuilder.new(benefit_file, args[:state_code])
      more_plan_data.run
      puts "Assigning complete complete"
    end
  end

  task :rate_data, [:state_code] => :environment do |task, args|
    rate_files = Dir.glob(File.join(Rails.root, "db/seedfiles/cms/2016", "**" ,"Rate_PUF_NV.csv"))
    rate_files.each do |rate_file|
      puts "Importing rate file  : #{rate_file}"

      plan_rate_data = PlanRateBuilder.new(rate_file, args[:state_code])
      plan_rate_data.run
      puts "Importing rates complete"
    end
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

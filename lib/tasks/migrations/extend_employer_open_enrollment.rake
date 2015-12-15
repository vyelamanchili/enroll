namespace :migrations do
  desc "Extend open enrollment period for 1/1 ERs to 12/28"
  task :extend_employers_open_enrollment => :environment do

    congressional_employers = {
      "Member-US House of Rep." => "536002522",
      "STAFF US House of Representatives" => "536002523",
      "United States Senate" => "536002558"
    }

    count  = 0
    Organization.exists(:employer_profile => true).each do |organization|
      employer_profile = organization.employer_profile
      next if employer_profile.renewing_plan_year.blank?
      next if congressional_employers.has_value?(employer_profile.fein)
    
      if employer_profile.renewing_plan_year.start_on == Date.new(2016,1,1)
        puts "Updating #{employer_profile.legal_name}"
        employer_profile.renewing_plan_year.open_enrollment_end_on = Date.new(2015, 12, 28)
        employer_profile.renewing_plan_year.imported_plan_year = true
        employer_profile.renewing_plan_year.save!
        count += 1
      end
    end

    puts "Processed #{count} employers."
  end
end
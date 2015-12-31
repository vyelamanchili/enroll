namespace :migrations do
  desc "Unpublish employers"
  task :unpublish_employer_benefits => :environment do
    
    employer_profile = Organization.where(legal_name: /L Squared Consulting LLC/i).first.employer_profile
    employer_profile.plan_years.published.each do |plan_year|
      puts plan_year.start_on
      if plan_year.start_on == Date.new(2016, 2, 1) && plan_year.benefit_groups.any? {|bg| bg.reference_plan.name  == "HealthyBlue Advantage Gold 1500" }
        plan_year.revert_application!
      end
    end

    employer_profile = Organization.where(legal_name: /InspireDC, Inc/i).first.employer_profile
    employer_profile.plan_years.published.each do |plan_year|
      if plan_year.start_on == Date.new(2016, 2, 1) && plan_year.benefit_groups.any? {|bg| bg.title  == "IDC Employee Benefit Package" }
        plan_year.revert_application!
      end
    end
  end
end
namespace :update_employer do
  desc "update planyear for employer profile so that employer is valid"
  task :plan_year => :environment do
  	Organization.where(employer_profile: {:$exists => true}).each{|org|org.employer_profile.plan_years.each{|py| py.benefit_groups.each{|bg|bg.unset(:_type)}}};nil
    eps = EmployerProfile.all.select {|ep| !ep.valid?}
    puts "There are #{eps.count} remaining invalid employer profiles"
    eps.each do |ep|
      ep.plan_years.each do |plan_year|
        puts "."
        if !plan_year.valid? && plan_year.errors.full_messages.include?("Open enrollment end on open enrollment must end on or before the 10th day of the month prior to effective date") && plan_year.start_on < TimeKeeper.date_of_record
          puts "Solved, #{ep.organization.legal_name} "
          plan_year.imported_plan_year = true
          plan_year.save
        else
          puts "Not yet resolved, #{ep.organization.legal_name}, #{ep.organization.fein}"
        end
      end
    end
  end
end
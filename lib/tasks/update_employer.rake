namespace :update_employer do
  desc "update planyear for employer profile so that employer is valid"
  task :plan_year => :environment do
    orgs = Organization.where(employer_profile: {:$exists => true}).no_timeout
    orgs.each{|org|org.employer_profile.plan_years.each{|py| py.benefit_groups.each{|bg|bg.unset(:_type)}}}
    invalid = orgs.all.select{|org| !org.valid?}
    eps = invalid.map(&:employer_profile)
    puts "There are #{eps.count} remaining invalid employer profiles"
    eps.each do |ep|
      ep.plan_years.each do |plan_year|
        if !plan_year.valid? && plan_year.errors.full_messages.include?("Open enrollment end on open enrollment must end on or before the 10th day of the month prior to effective date") && plan_year.start_on < TimeKeeper.date_of_record
          puts "Solved, #{ep.organization.legal_name} "
          plan_year.imported_plan_year = true
          plan_year.save
        else
          puts "Not yet resolved, #{ep.organization.legal_name}, #{ep.organization.fein}"
        end
      end
    end
    invalid2 = orgs.all.select{|org| bad=!org.valid?; puts org.legal_name if bad; bad}
  end
end
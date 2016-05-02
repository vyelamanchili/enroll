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

  
  desc "delete all nil addresses for office locations"
  task :delete_nil_addresses => :environment do
    
    invalid_orgs = Organization.where("office_locations.address" => nil).all
    # The invalid_orgs list can be of the following types:  1. with a nil or blank[] office_locations, 2. with a nil address for some office_location. 
    # Both of these cases will fail the validation and the Organization.save will fail.
    invalid_orgs.each do |org|
      office_locations = org.office_locations
      if office_locations.present?
        office_locations.each do |off_loc|
          if off_loc.address.blank?
            puts "This is a bad office_location with no address => ID : (#{off_loc.id}) of #{org.legal_name}. This office_location will be deleted to make the organization valid."
            org.office_locations.where(id: off_loc.id).first.delete
          end
        end
      else
         puts " *** FOUND ORGANIZATION WITHOUT ANY OFFICE LOCATION, ASK BUSINESS TO UPDATE A PRIMARY OFFICE LOCATION FOR : #{org.legal_name} "
      end  
    end

  end


end 
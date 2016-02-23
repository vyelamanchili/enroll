# ticket https://devops.dchbx.org/redmine/issues/5142
# this script will export employers with dental plans in plan_years

organizations = Organization.where(:employer_profile.exists => true)

organizations.each do |org|
  org.employer_profile.plan_years.flat_map(&:benefit_groups).each do |benefit_group|
    benefit_group.elected_plans.each do |elected_plan|
      begin
        if elected_plan.coverage_kind == 'dental'
          puts "#{org.employer_profile.legal_name}, #{org.employer_profile.fein}, #{benefit_group.title}, #{elected_plan.name},  #{elected_plan.hios_id}, #{benefit_group.plan_year.start_on}"
        end
      rescue Exception => e
        puts "#{org.id} " + e.message
      end
    end
  end
end

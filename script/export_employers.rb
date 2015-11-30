employers = Organization.where("employer_profile" => {"$exists" => true}).map(&:employer_profile)
EXCLUDED_ATTRIBUTES = %w(aasm_state updated_at created_at)

EMPTY_COLUMN = ","
def keys_values(document)
  return_values = []
  document.attributes.keys.each do |key|
    next if (document.attributes[key].is_a? BSON::Document) || (document.attributes[key].is_a? Array)
    next if EXCLUDED_ATTRIBUTES.include? key
    return_values << document.attributes[key]
  end
  return_values
end

def add_to_csv(empty_columns, type, object, csv)
  op = [type]
=begin
  empty_columns.times do |n|
    op.unshift("",)
  end
=end
  op.append keys_values(object)
  csv << op.flatten
end

CSV.open("employer_export.csv", "w") do |csv|
  employers.each do |employer|
    add_to_csv(0, "EMPLOYER", employer, csv)
    add_to_csv(0, "ORGANIZATION", employer.organization, csv)

    employer.organization.office_locations.each do |office_location|
      add_to_csv(1, "OFFICE LOCATION", office_location, csv)
      add_to_csv(1, "ADDRESS", office_location.address, csv)
      add_to_csv(1,  "PHONE", office_location.phone, csv)
    end

    if employer.employer_profile_account.present?
      add_to_csv(1, "EMPLOYER PROFILE ACCOUNT", employer.employer_profile_account, csv)
    end

    employer.broker_agency_accounts.each do |broker_agency_account|
      add_to_csv(1, "BROKER AGENCY ACCOUNT", broker_agency_account, csv)
    end

    employer.census_employees.each do |census_employee|
      add_to_csv(1, "CENSUS EMPLOYEE", census_employee, csv)

      census_employee.census_dependents.each do |census_dependent|
        add_to_csv(2, "CENSUS DEPENDENTS", census_dependent, csv)
      end
    end

    employer.plan_years.each do |plan_year|
      add_to_csv(1, "PLAN YEAR", plan_year, csv)

      plan_year.benefit_groups.each do |benefit_group|
        add_to_csv(2, "BENEFIT GROUP", benefit_group, csv)

        benefit_group.relationship_benefits.each do |relationship_benefit|
          add_to_csv(3, "RELATIONSHIP BENEFIT", relationship_benefit, csv)
        end

        benefit_group.elected_plans.each do |elected_plan|
          add_to_csv(3, "ELECTED PLAN", elected_plan, csv)
        end
      end
    end
  end
end



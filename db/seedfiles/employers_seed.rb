puts "*"*80
puts "::: Cleaning Employers :::"
Employer.delete_all

# Retrieve Brokers
broker_agency_0 = BrokerAgency.first
broker_agency_1 = BrokerAgency.last

# Employer addresses
employer_address_1 = Address.new(kind: "mailing", address_1: "13025 Elm Tree CT", address_2: "Suite 300", city: "Herndon", state: "VA", county: "Fairfax", zip: "20172", country_name: "USA")
employer_address_2 = Address.new(kind: "work", address_1: "320 W Illinois St", address_2: "suite 180", city: "Chicago", state: "IL", county: "Chicago", zip: "60654", country_name: "USA")
employer_address_3 = Address.new(kind: "home", address_1: "43 Russells Way", address_2: "Suite 23", city: "Westford", state: "MA", county: "", zip: "01886", country_name: "USA")
employer_address_4 = Address.new(kind: "home", address_1: "20178 E Hampden PL", address_2: "Suite 45", city: "Aurora", state: "CO", county: "", zip: "80013", country_name: "USA")
employer_address_5 = Address.new(kind: "work", address_1: "1010 Potomac Rd", address_2: "APT 102", city: "Atlanta", state: "GA", county: "Fulton", zip: "30338", country_name: "USA")

puts "::: Generating Employers :::"
# Employer creation
employer_1 = Employer.create!(entity_kind: "c_corporation", fein: "897897897", dba: "1234", legal_name: "Global Systems", is_active: true, addresses: [employer_address_1], broker_agency: broker_agency_0)
employer_2 = Employer.create!(entity_kind: "partnership", fein: "397897897", dba: "3434", legal_name: "Technology Solutions Inc", is_active: true, addresses:[employer_address_2], broker_agency: broker_agency_0)
employer_3 = Employer.create!(entity_kind: "s_corporation", fein: "597897897", dba: "9034", legal_name: "Futurewave Systems Inc", is_active: true, addresses:[employer_address_3], broker_agency: broker_agency_0)
employer_4 = Employer.create!(entity_kind: "tax_exempt_organization", fein: "797897897", dba: "8934", legal_name: "Primus Software Corporation", is_active: true,  addresses:[employer_address_4], broker_agency: broker_agency_1)
employer_5 = Employer.create!(entity_kind: "partnership", fein: "997897897", dba: "5634", legal_name: "OneCare", is_active: false, addresses:[employer_address_5])

puts "::: Created 5 Employers :::"

# Employee Addresses
address_0 = Address.new(kind: "home", address_1: "1225 I St, NW", address_2: "Apt A7", city: "Washington", state: "DC", county: "Fairfax", zip: "20004", country_name: "USA")
address_1 = Address.new(kind: "work", address_1: "145 I45 St", address_2: "suite 200", city: "Washington", state: "DC", county: "Fairfax", zip: "20004", country_name: "USA")
address_2 = Address.new(kind: "home", address_1: "1 North State St", address_2: "suite 100", city: "Chicago", state: "IL", county: "chicago", zip: "60654", country_name: "USA")
address_3 = Address.new(kind: "mailing", address_1: "4900 USAA BLVD", address_2: "", city: "San Antonio", state: "TX", county: "Buxton", zip: "78240", country_name: "USA")
address_4 = Address.new(kind: "work", address_1: "1 Clear Crk", address_2: "", city: "Irvine", state: "CA", county: "Irvine", zip: "92620", country_name: "USA")
address_5 = Address.new(kind: "home", address_1: "15 Darlington", address_2: "suite 998", city: "Irvine", state: "CA", county: "Irvine", zip: "92620", country_name: "USA")

# Employee and Dependents Creation
employee_0 = EmployerCensus::Employee.new(first_name: "Guy", last_name: "Noir", dob: "01/12/1950", gender: "male", employee_relationship: "self", hired_on: "01/01/2014", ssn: "011222330", address: address_0)

employee_1 = EmployerCensus::Employee.new(first_name: "John", last_name: "Doe", dob: "01/12/1980", gender: "male", employee_relationship: "self", hired_on: "01/01/2014", ssn: "111222333", address: address_1)
dependent_1_1 = EmployerCensus::Dependent.new(first_name: "Matt", last_name: "Doe", dob: "01/12/2011", gender: "male", employee_relationship: "child", ssn: "222333111")
dependent_1_2 = EmployerCensus::Dependent.new(first_name: "Jessica", last_name: "Doe", dob: "02/12/1982", gender: "female", employee_relationship: "spouse", ssn: "212333111")
dependent_1_3 = EmployerCensus::Dependent.new(first_name: "Caroline", last_name: "Doe", dob: "02/12/2010", gender: "female", employee_relationship: "child", ssn: "212333211")

puts "::: Generating Employer Rosters :::"

# Employee Family Creation
family_0 = employer_1.employee_families.new
family_0.employee = employee_0
family_0.save!

family_1 = employer_1.employee_families.new
family_1.employee = employee_1
family_1.dependents = [dependent_1_1, dependent_1_2, dependent_1_3]
family_1.save!

employee_2 = EmployerCensus::Employee.new(first_name: "Melaine", last_name: "Roger", dob: "01/15/1975", gender: "male", employee_relationship: "self", hired_on: "12/01/2012", ssn: "111422333", address: address_2)
dependent_2_1 = EmployerCensus::Dependent.new(first_name: "Martina", last_name: "Roger", dob: "01/31/2011", gender: "female", employee_relationship: "child", ssn: "222333141")
dependent_2_2 = EmployerCensus::Dependent.new(first_name: "Monica", last_name: "Roger", dob: "02/09/1983", gender: "female", employee_relationship: "spouse", ssn: "212333311")
dependent_2_3 = EmployerCensus::Dependent.new(first_name: "Caroline", last_name: "Roger", dob: "04/12/2010", gender: "female", employee_relationship: "child", ssn: "212339211")

family_2 = employer_2.employee_families.new
family_2.employee = employee_2
family_2.dependents = [dependent_2_1, dependent_2_2, dependent_2_3]
family_2.save!

employee_3 = EmployerCensus::Employee.new(first_name: "Kareena", last_name: "Johnson", dob: "01/15/1978", gender: "female", employee_relationship: "self", hired_on: "04/01/2011", ssn: "151422333", address: address_3)
dependent_3_1 = EmployerCensus::Dependent.new(first_name: "Melissa", last_name: "Johnson", dob: "12/31/2011", gender: "female", employee_relationship: "child", ssn: "222333131")
dependent_3_2 = EmployerCensus::Dependent.new(first_name: "Martin", last_name: "Johnson", dob: "02/19/1972", gender: "male", employee_relationship: "spouse", ssn: "812353311")
dependent_3_3 = EmployerCensus::Dependent.new(first_name: "Frazier", last_name: "Johnson", dob: "04/16/2010", gender: "male", employee_relationship: "child", ssn: "212439261")

family_3 = employer_3.employee_families.new
family_3.employee = employee_3
family_3.dependents = [dependent_3_1, dependent_3_2, dependent_3_3]
family_3.save!

employee_4 = EmployerCensus::Employee.new(first_name: "Mario", last_name: "Gomez", dob: "01/25/1968", gender: "male", employee_relationship: "self", hired_on: "02/02/2011", ssn: "151422930", address: address_4)
dependent_4_1 = EmployerCensus::Dependent.new(first_name: "Paula", last_name: "Gomez", dob: "12/29/2010", gender: "female", employee_relationship: "child", ssn: "222333031")
dependent_4_2 = EmployerCensus::Dependent.new(first_name: "Martina", last_name: "Gomez", dob: "02/19/1982", gender: "female", employee_relationship: "spouse", ssn: "812353398")
dependent_4_3 = EmployerCensus::Dependent.new(first_name: "Rafael", last_name: "Gomez", dob: "04/16/2012", gender: "male", employee_relationship: "child", ssn: "212439267")

family_4 = employer_4.employee_families.new
family_4.employee = employee_4
family_4.dependents = [dependent_4_1, dependent_4_2, dependent_4_3]
family_4.save!

employee_5 = EmployerCensus::Employee.new(first_name: "Martina", last_name: "Williams", dob: "01/25/1990", gender: "female", employee_relationship: "self", hired_on: "02/02/2014", ssn: "151482930", address: address_5)

family_5 = employer_5.employee_families.new
family_5.employee = employee_5
family_5.save!

puts "::: Employers Complete :::"
puts "*"*80


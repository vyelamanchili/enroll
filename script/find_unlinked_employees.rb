
## Find all people who have an employee role. 
all_employee_users = User.where(:roles => {"$in" => ["employee"]})
all_employee_persons = Person.where(:employee_roles => {"$ne" => nil})

## This goes through and checks each of these people to see if they are currently enrolled 
all_employee_persons.each do |employee_person|
	census_emp = employee_person.employee_roles.first.census_employee
	if census_emp.aasm_state == "eligible"
		census_emp.aasm_state = "employee_role_linked"
		census_emp.save
	end
end
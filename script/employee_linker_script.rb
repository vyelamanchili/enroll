## This script takes employees who have created an account and have a linkage and changes their aasm state. 

filename = 'unlinked_employees.csv'

CSV.foreach(filename, headers: true) do |row|
	data_row = row.to_hash
	person = Person.where(hbx_id: data_row["HBX ID"]).first
	census_employee = person.employee_roles.first.census_employee
	binding.pry
	if census_employee.aasm_state == "eligible"
		census_employee.aasm_state = "employee_role_linked"
		census_employee.save
	end
end

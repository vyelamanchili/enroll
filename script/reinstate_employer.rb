puts "What is the FEIN of the employer you need to reinstate?"
fein = gets.chomp.to_s

fein = fein.strip.gsub("-","")

employer = Organization.where(fein: fein).first

if employer == nil
	puts "I can't find this employer."
else
	emp_plan_years = employer.employer_profile.plan_years
	plan_year_count = emp_plan_years.count
	if plan_year_count == 1
		employer.employer_profile.plan_years.first.update_attributes({'aasm_state' => 'active'})
	elsif plan_year_count > 1
		puts "Which plan year do you want to reinstate?"
		emp_plan_years.each do |plan_year|
			puts "#{emp_plan_years.index(plan_year)} - #{plan_year.start_on}-#{plan_year.end_on}"
		end
		reinstate_py = gets.chomp.to_i
		emp_plan_years[reinstate_py].update_attributes({'aasm_state' => 'active'})
	end
end
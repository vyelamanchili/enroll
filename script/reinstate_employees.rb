puts "Please enter enrollment group ids of the policies"
hbx_ids = gets.chomp.to_s.split(',')

hbx_ids.each do |id|
	family = Family.where("households.hbx_enrollments.hbx_id" => id.to_s).first
	family.households.each do |household|
		household.hbx_enrollments.each do |hbx_enrollment|
			if hbx_enrollment.hbx_id == id.to_s
				hbx_enrollment.update_attributes({:aasm_state => 'coverage_enrolled'}) 
				hbx_enrollment.benefit_group_assignment.make_active
				hbx_enrollment.benefit_group_assignment.select_coverage! if hbx_enrollment.benefit_group_assignment.may_select_coverage?
			end
		end
	end
end
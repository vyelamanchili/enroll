# This script requires a text file with a list of policy IDs. 

policy_ids = []

File.readlines('policies_to_reinstate.txt').map do |line|
	policy_ids.push(line.to_s)
end

policy_ids.each do |id|
	family = Family.where("households.hbx_enrollments.hbx_id" => id.to_s)
	family.households.each do |household|
		household.hbx_enrollments.each do |hbx_enrollment|
			if hbx_enrollment.hbx_id == id.to_s
				hbx_enrollment.update_attributes({:aasm_state => 'coverage_enrolled'})
				hbx_enrollment.benefit_group_assignment.make_active
				hbx_enrollment.benefit_group_assignment.select_coverage!
				hbx_enrollment.save!
			end
		end
	end
end
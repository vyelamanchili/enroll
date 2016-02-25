ENROLLMENT_CANCELLABLE_STATES = [:auto_renewing, :renewing_coverage_selected, :renewing_transmitted_to_carrier,
                                 :renewing_coverage_enrolled, :coverage_selected, :transmitted_to_carrier, :coverage_renewed,
                                 :enrolled_contingent, :unverified, :renewing_waived]

dental_plans = Plan.where(:coverage_kind => "dental")
dental_ids = dental_plans.map(&:id)
families = Family.where({"households.hbx_enrollments" => {"$elemMatch" => {"benefit_group_id" => {"$ne" => nil}, "plan_id" => {"$in" => dental_ids}}}})

families.each do |fam|
  fam.households.each do |hh|
    hh.hbx_enrollments.each do |en|
      if (!en.benefit_group_assignment_id.nil?) && (!en.plan_id.blank?) && en.plan.coverage_kind == "dental"
        puts en.hbx_id
        other_health_policy = fam.households.flat_map(&:hbx_enrollments).select do |other_en|
          (other_en.benefit_group_assignment_id == en.benefit_group_assignment_id) &&
              (!other_en.plan.nil?) &&
              (other_en.plan.coverage_kind == "health") &&
              (other_en.aasm_state == "coverage_selected")
        end
        latest_health = other_health_policy.sort_by(&:submitted_at).last

        if ENROLLMENT_CANCELLABLE_STATES.include? en.aasm_state.to_sym
          hbx_enrollment.cancel_coverage!
        else
          hbx_enrollment.aasm_state = 'coverage_canceled'
        end

        en.terminated_on = en.effective_on
        en.hbx_enrollment_members.each do |hbx_enrollment_member|
          hbx_enrollment_member.coverage_end_on = hbx_enrollment_member.coverage_start_on
        end
        en.coverage_kind = 'dental'
        en.save!

        benefit_group_assignment = en.benefit_group_assignment
        benefit_group_assignment.hbx_enrollment_id = latest_health.id
        benefit_group_assignment.save!
      end
    end
  end
end
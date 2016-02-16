# ticket https://devops.dchbx.org/redmine/issues/5142
# this script will export family, hbx_enrollment, plan details for dental plans mistakenly shopped in shop

csv = CSV.open("dental_plans_in_shop.csv", "w")
csv << %w(hbx_enrollment.household.family.id, hbx_enrollment.id, hbx_enrollment.plan.id, hbx_enrollment.plan.name,
          hbx_enrollment.coverage_kind, hbx_enrollment.plan.coverage_kind hbx_enrollment.kind hbx_enrollment.created_at hbx_enrollment.aasm_state after_11_01)

Family.all.flat_map(&:households).flat_map(&:hbx_enrollments).each do |hbx_enrollment|
  begin
    if hbx_enrollment.coverage_kind != hbx_enrollment.plan.coverage_kind
      csv << [hbx_enrollment.household.family.id, hbx_enrollment.id, hbx_enrollment.plan.id,
              hbx_enrollment.plan.name, hbx_enrollment.coverage_kind, hbx_enrollment.plan.coverage_kind,
              hbx_enrollment.kind, hbx_enrollment.created_at, hbx_enrollment.aasm_state, hbx_enrollment.created_at > Date.new(2015, 11, 01)]
    end
  rescue Exception => e
    #puts "Family #{hbx_enrollment.household.family.id} hbx_enrollment #{hbx_enrollment.id} " + e.message
  end
end
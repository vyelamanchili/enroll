# ticket https://devops.dchbx.org/redmine/issues/5142
# this script will fix dental enrollments which mistakenly have coverage_kind = 'health'

csv = CSV.open("fixed_dental_enrollments.csv", "w")
csv << %w(hbx_enrollment.household.family.id, hbx_enrollment.id
          hbx_enrollment.coverage_kind, hbx_enrollment.plan.coverage_kind hbx_enrollment.kind )

Family.all.flat_map(&:households).flat_map(&:hbx_enrollments).each do |hbx_enrollment|
  begin
    if hbx_enrollment.coverage_kind == 'health' && hbx_enrollment.plan.coverage_kind == 'dental'
      hbx_enrollment.coverage_kind = 'dental'
      hbx_enrollment.save
      hbx_enrollment.reload
      csv << [hbx_enrollment.household.family.id, hbx_enrollment.id, hbx_enrollment.coverage_kind,
              hbx_enrollment.plan.coverage_kind, hbx_enrollment.kind]
    end
  rescue Exception => e
    puts "Family #{hbx_enrollment.household.family.id} hbx_enrollment #{hbx_enrollment.id} " + e.message
  end
end
# Daily Report: Rake task to find census employee's who terminated their hbx_enrollment on previous date
# To Run Rake Task: RAILS_ENV=production rake reports:census_employee:termination_submitted_on
require 'csv'

namespace :reports do
  namespace :census_employee do

    desc "List of census employee's terminated their hbx_enrollment yesterday "
    task :termination_submitted_on => :environment do

      start_date = Date.yesterday.beginning_of_day
      end_date = Date.yesterday.end_of_day
      # find families who terminated their hbx_enrollments
      families = Family.by_enrollment_shop_market.
                  any_in(:"households.hbx_enrollments.aasm_state" => HbxEnrollment::TERMINATED_STATUSES).
                  by_enrollment_updated_datetime_range(start_date, end_date)
      field_names  = %w(
               HBX_ID
               Enrolled_Member_First_Name
               Enrolled_Member_Last_Name
               Employer_Legal_Name
               Fein
               Primary_Member_First_Name
               Primary_Member_Last_Name
               Market_Kind
               Plan_Name
               HIOS_ID
               Policy_ID
               Effective_Start_Date
               End_Date
               Termination_Submitted_On
             )
      processed_count = 0
      Dir.mkdir("hbx_report") unless File.exists?("hbx_report")
      file_name = "#{Rails.root}/hbx_report/employee_termination_submitted_on_report.csv"

      CSV.open(file_name, "w", force_quotes: true) do |csv|
        csv << field_names

        families.each do |family|
          # reject if doesn't have active_employee_roles
          next unless family.primary_family_member.person.active_employee_roles
          # find hbx_enrollments who's aasm state=coverage_terminated and updated date (date termination submitted)== yesterday day
          hbx_enrollments = [family].flat_map(&:households).flat_map(&:hbx_enrollments).select{|hbx| hbx.aasm_state == "coverage_terminated" && hbx.updated_at.strftime('%Y-%m-%d') == Date.yesterday.strftime('%Y-%m-%d')}
          hbx_enrollment_members = hbx_enrollments.flat_map(&:hbx_enrollment_members)
          hbx_enrollment_members.each do |hbx_enrollment_member|
            if hbx_enrollment_member
              csv << [
                  hbx_enrollment_member.person.hbx_id,
                  hbx_enrollment_member.person.first_name,
                  hbx_enrollment_member.person.last_name,
                  family.primary_family_member.person.active_employee_roles.first.employer_profile.legal_name,
                  family.primary_family_member.person.active_employee_roles.first.employer_profile.fein,
                  family.primary_family_member.person.first_name,
                  family.primary_family_member.person.last_name,
                  hbx_enrollment_member.hbx_enrollment.kind,
                  hbx_enrollment_member.hbx_enrollment.plan.name,
                  hbx_enrollment_member.hbx_enrollment.plan.hios_id,
                  hbx_enrollment_member.hbx_enrollment.hbx_id,
                  hbx_enrollment_member.hbx_enrollment.effective_on,
                  hbx_enrollment_member.hbx_enrollment.terminated_on,
                  hbx_enrollment_member.hbx_enrollment.updated_at
              ]
            end
            processed_count += 1
          end
        end
        puts "For date #{start_date}, total census employee's terminated their hbx_enrollment count #{processed_count} and census employee's information output file: #{file_name}"
      end
    end
  end
end
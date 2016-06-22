namespace :migrations do

  desc "Cancel renewal for employer"
  task :terminate_ee_coverage, [:fein, :first_name, :last_name, :ssn, :termination_date] => [:environment] do |task, args|

    termination_date = Date.strptime(args[:termination_date], "%m/%d/%Y")
    employer_profile = EmployerProfile.find_by_fein(args[:fein])
    plan_year = employer_profile.plan_years.published_plan_years_by_date(termination_date).first
    plan_year = employer_profile.plan_years.where(:aasm_state => 'expired').detect{|py| (py.start_on..py.end_on).cover?(termination_date)} if plan_year.blank?

    if plan_year.present?
      people = Person.where(:first_name => /#{args[:first_name]}/i, :last_name => /#{args[:last_name]}/i, :encrypted_ssn => Person.encrypt_ssn(args[:ssn]))

      if people.blank?
        raise 'unable to find person record'
      end

      if people.size > 1
        raise 'more than 1 match found'
      end

      people.each do |person|
        enrollments = person.primary_family.enrollments
        enrollments.where(:benefit_group_id.in => plan_year.benefit_groups.map(&:id)).enrolled.each do |hbx_enrollment|
          if hbx_enrollment.may_terminate_coverage?
            hbx_enrollment.update_attributes(:terminated_on => termination_date)
            hbx_enrollment.terminate_coverage!
            hbx_enrollment.propogate_terminate(termination_date)
            puts "terminated coverage for #{person.full_name}"
          end
        end

        enrollments.renewing.each do |hbx_enrollment|
          if hbx_enrollment.may_cancel_coverage?
            hbx_enrollment.cancel_coverage!
          end
          puts "cancel renewing coverage for #{person.full_name}"
        end
      end
    end
  end
end
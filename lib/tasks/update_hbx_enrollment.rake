namespace :update_hbx do
  desc "update carrier_profile_id for hbx_enrollments"
  task :carrier_profile_id => :environment do 
    count = 0
    families = Family.ne("households.hbx_enrollments"=> nil)
    families.each do |family|
      households = family.households.ne("hbx_enrollments" => nil)
      households.each do |household|
        hbxs = household.hbx_enrollments.ne('plan_id' => nil).where('carrier_profile_id'=> nil)
        hbxs.each do |hbx|
          if hbx.carrier_profile_id.blank? and hbx.plan_id.present?
            plan = Plan.where(id: hbx.plan_id).last
            if plan.present?
              hbx.update_current(carrier_profile_id: hbx.plan.try(:carrier_profile_id)) 
              count += 1
              puts "updated #{count} hbx_enrollment"
            end
          end
        end
      end
    end
    puts "updated #{count} hbx_enrollments for carrier_profile_id"
  end
end

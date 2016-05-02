namespace :data do
  task :update_nv_plans, [:file] => :environment do |task, args|

    puts "*"*80
    puts "updating plans"

    # Update carefirst legal name to cigna
    org = Organization.where(legal_name: "CareFirst").first
    if org.present?
      org.legal_name = "Cigna"
      org.save
    end

    # update a specific plan
    plan = Plan.where(hios_id: /86052DC0460019-01/).last
    if plan.present?
      plan.name = "Cigna HMO HSA Silver Plan"
      plan.deductible = "$1,750"
      plan.save
      csv = Products::QhpCostShareVariance.find_qhp_cost_share_variances(["#{plan.hios_id}"], 2016, "health").first
      moop = csv.qhp_maximum_out_of_pockets.where(name: "Maximum Out of Pocket for Medical and Drug EHB Benefits (Total)").last
      moop.in_network_tier_1_individual_amount = "$3,700"
      moop.in_network_tier_1_family_amount = "$3700 per person | $7400 per group"
      moop.save
    end

    # remove references to blue choice in plan names
    plans = Plan.where(name: /BlueChoice/)
    plans.each do |pln|
      pln.name = pln.name.gsub("BlueChoice ", "")
      pln.save
    end

  puts "updating plans completed"
  puts "*"*80
  end

end
require 'yajl'

namespace :seed do
  desc "Load the policy_statistics.json file"
  task :policy_statistics_json => :environment do
    #p_json_file = File.open("db/seedfiles/policy_statistics1.json")
    #p_json = JSON.load(p_json_file.read)

    start_time = Time.now
    puts "start to load json file."
    json = File.new('db/seedfiles/policy_statistics.json', 'r')
    puts "finish load json file. #{Time.now - start_time}"
    parser = Yajl::Parser.new
    p_json = parser.parse(json)

    count = 0

    puts "clear old data of analytics #{Time.now - start_time}"
    PolicyStatistic.delete_all
    p_json.each do |b_rec|
      thr = Thread.new do
        plan = b_rec['plan'] || {}

        PolicyStatistic.create(
          oid: b_rec['_id']['$oid'],
          start_on: DateTime.iso8601(b_rec['policy_start_on']['$date']),
          family_created_at: DateTime.iso8601(b_rec['family_created_at']['$date']),
          purchased_at: DateTime.iso8601(b_rec['policy_purchased_at']['$date']),
          member_count: b_rec['member_count'],
          enrollment_kind: b_rec['enrollment_kind'],
          aasm_state: b_rec['aasm_state'],
          hbx_id: b_rec['hbx_id'],
          coverage_kind: b_rec['coverage_kind'],
          family_id: (b_rec['family_id']['$oid'] rescue ''),
          rp_ids: b_rec['rp_ids'],
          state_transitions: b_rec['state_transitions'],
          benefit_group_id: (b_rec['benefit_group_id']['$oid'] rescue ''),
          benefit_group_assignment_id: (b_rec['benefit_group_assignment_id']['$oid'] rescue ''),
          plan_id: (plan['_id']['$oid'] rescue ''),
          plan_ehb: plan['ehb'],
          plan_minimum_age: plan['minimum_age'],
          plan_maximum_age: plan['maximum_age'],
          plan_is_active: plan['is_active'],
          plan_name: plan['name'],
          plan_hios_id: plan['hios_id'],
          plan_hios_base_id: plan['hios_base_id'],
          plan_csr_variant_id: plan['csr_variant_id'],
          plan_active_year: plan['active_year'],
          plan_metal_level: plan['metal_level'],
          plan_market: plan['market'],
          plan_carrier_profile_id: plan['carrier_profile_id'],
          plan_coverage_kind: plan['coverage_kind'],
          plan_is_standard_plan: plan['is_standard_plan'],
          plan_type: plan['plan_type'],
          plan_deductible: plan['deductible'],
          plan_family_deductible: plan['family_deductible'],
          plan_nationwide: plan['nationwide'],
          plan_dc_in_network: plan['dc_in_network']
        )
        puts "#{count}"
        count += 1
      end
      thr.join
    end
    puts "-----------------load #{count}-------------"
  end
end


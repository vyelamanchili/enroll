class PolicyStatistic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :oid, type: String
  field :start_on, type: DateTime
  field :family_created_at, type: DateTime
  field :purchased_at, type: DateTime
  field :member_count, type: Integer
  field :enrollment_kind, type: String
  field :aasm_state, type: String
  field :hbx_id, type: String
  field :coverage_kind, type: String
  field :family_id, type: String
  field :rp_ids, type: Array, default: []
  field :state_transitions, type: Array, default: []
  field :benefit_group_id, type: String
  field :benefit_group_assignment_id, type: String

  field :plan_id, type: String
  field :plan_ehb, type: Float, default: 0.0
  field :plan_minimum_age, type: Integer, default: 0
  field :plan_maximum_age, type: Integer, default: 120
  field :plan_is_active, type: Boolean, default: true
  field :plan_name, type: String
  field :plan_hios_id, type: String
  field :plan_hios_base_id, type: String
  field :plan_csr_variant_id, type: String
  field :plan_active_year, type: Integer
  field :plan_metal_level, type: String
  field :plan_market, type: String
  field :plan_carrier_profile_id, type: String
  field :plan_coverage_kind, type: String
  field :plan_is_standard_plan, type: Boolean, default: false
  field :plan_type, type: String
  field :plan_deductible, type: String
  field :plan_family_deductible, type: String
  field :plan_nationwide, type: Boolean, default: false
  field :plan_dc_in_network, type: Boolean, default: false

  def self.report(market='individual', coverage_kind='health', aasm_state='coverage_selected')
    PolicyStatistic.collection.aggregate([
      {'$match': {plan_market: market}}, 
      {'$match': {coverage_kind: coverage_kind}}, 
      {'$match': {aasm_state: aasm_state}}, 
      {'$match': {start_on: {"$gte" => Date.new(2015,1,1)}}},
      {'$group': {_id:{member_count: '$member_count', metal_level:'$plan_metal_level'}, count: {'$sum':1}}}
    ],
    :allow_disk_use => true).entries
  end

  def self.report_for_chart(market='individual', coverage_kind='health', aasm_state='coverage_selected')
    records = self.report(market, coverage_kind, aasm_state)
    options = records.map{|r| r["_id"]["member_count"]}.uniq.sort
    report_data = []
    Plan::METAL_LEVEL_KINDS.each do |ml|
      ha = {}
      records.select {|r| r["_id"]["metal_level"] == ml}.sort{|r| r["_id"]["member_count"]}.each{|r| ha[r['_id']['member_count']] = r['count']}
      missing = options - ha.keys
      missing.each {|m| ha[m]=0}
      report_data << {:name => ml, :data => Hash[ha.sort_by{|key, val|key}].values}
    end

    [options, report_data]
  end
end

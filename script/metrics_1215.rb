qi = Queries::PolicyAggregationPipeline.new
qs = Queries::PolicyAggregationPipeline.new

qi.filter_to_individual.with_effective_date({"$gt" => Date.new(2015,12,31), "$lt" => Date.new(2016,1,2)})
qs.filter_to_shop.with_effective_date({"$gt" => Date.new(2015,12,31), "$lt" => Date.new(2016,1,2)})

puts "Individual 1/1:"
puts qi.count


cong_hbx_ids = ["100101","100102","118510"]

orgs = Organization.where(:hbx_id => {"$in" => cong_hbx_ids})

benefit_group_ids = orgs.map(&:employer_profile).flat_map(&:plan_years).flat_map(&:benefit_groups).map(&:id)
qs.add({
  "$match" => {
    "households.hbx_enrollments.benefit_group_id" => { "$in" => benefit_group_ids }
  }
})

puts "Congress 1/1:"
puts qs.count

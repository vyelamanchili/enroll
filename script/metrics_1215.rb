qi = Queries::PolicyAggregationPipeline.new
qi.filter_to_individual.with_effective_date({"$gt" => Date.new(2015,12,31), "$lt" => Date.new(2016,1,2)})

puts "Individual 1/1:"
puts qi.count

cong_hbx_ids = ["100101","100102","118510"]

qs = Queries::PolicyAggregationPipeline.new
qs.filter_to_employers_hbx_ids(cong_hbx_ids).filter_to_shop.with_effective_date({"$gt" => Date.new(2015,12,31), "$lt" => Date.new(2016,1,2)})

puts "Congress 1/1:"
puts qs.count

qs_binned = Queries::PolicyAggregationPipeline.new
qs_binned.filter_to_employers_hbx_ids(cong_hbx_ids).filter_to_shop.with_effective_date({"$gt" => Date.new(2015,12,31), "$lt" => Date.new(2016,1,2)})

puts "Congress 1/1 enrollment by day:"
qs_binned.group_by_purchase_date.each do |rec|
  puts rec.join(" - ")
end

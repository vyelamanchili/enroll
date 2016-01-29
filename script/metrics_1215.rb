cong_hbx_ids = ["100101","100102","118510"]

qs = Queries::PolicyAggregationPipeline.new

qs.filter_to_individual.with_effective_date({"$gt" => Date.new(2015,12,31), "$lt" => Date.new(2016,1,2)}) #.eliminate_family_duplicates

qs.remove_duplicates_by_family.each do |rec|
  puts rec.join(" - ")
end

#qs.add({
#  "$match" => {
#    "policy_purchased_at" => {"$gte" => Time.new(2015,11,29,11,55,00,"-05:00") }
#  }
#})

#qs.evaluate.each do |r|
#  puts r['hbx_id']
#end

# puts "Individual 1/1:"
# puts qi.count

# puts "IVL 1/1 dental OE by day:"
# qi.remove_duplicates_by_family_as_sep.each do |rec|
#  puts rec.join(" - ")
# end

# puts "Congress 1/1:"
# puts qs.count
#qs_binned = Queries::PolicyAggregationPipeline.new
#qs_binned.filter_to_employers_hbx_ids(cong_hbx_ids).filter_to_shop.with_effective_date({"$gt" => Date.new(2015,12,31), "$lt" => Date.new(2016,1,2)})

#puts "Congress 1/1 renewal enrollment by day:"
#qs_binned.remove_duplicates_by_family_as_renewals.each do |rec|
#  puts rec.join(" - ")
#end

#qs_dec = Queries::PolicyAggregationPipeline.new
#qs_dec.filter_to_shop.exclude_employers_by_hbx_ids(cong_hbx_ids).open_enrollment.with_effective_date({"$gt" => Date.new(2015,11,30), "$lt" => Date.new(2015,12,2)})

#puts "12/1 Shop Policies - Open Enrollment, non-congress:"
#qs_dec.remove_duplicates_by_family.each do |rec|
#  puts rec.join(" - ")
#end

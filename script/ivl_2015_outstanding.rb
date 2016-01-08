qs = Queries::PolicyAggregationPipeline.new

qs.filter_to_individual.filter_to_active.with_effective_date({"$gt" => Date.new(2015,9,30), "$lt" => Date.new(2016,1,2)}).eliminate_family_duplicates
# qs.filter_to_individual.with_effective_date({"$gt" => Date.new(2016,1,1)}).eliminate_family_duplicates
#qs.filter_to_shop.filter_to_employers_hbx_ids(cong_hbx_ids).with_effective_date({"$gt" => Date.new(2016,1,1)}).eliminate_family_duplicates
#qs.filter_to_shop.filter_to_employers_feins(feins).with_effective_date({"$gt" => Date.new(2015,12,31), "$lt" => Date.new(2016,1,2)}).eliminate_family_duplicates
# qs.filter_to_individual.filter_to_active.with_effective_date({"$gt" => Date.new(2015,12,31), "$lt" => Date.new(2016,1,2)}).eliminate_family_duplicates
#qs.filter_to_shop.exclude_employers_by_hbx_ids(cong_hbx_ids).with_effective_date({"$gt" => Date.new(2015,12,31), "$lt" => Date.new(2016,1,2)}).eliminate_family_duplicates
#qs.filter_to_shop.filter_to_employers_hbx_ids(cong_hbx_ids).with_effective_date({"$gt" => Date.new(2015,10,31), "$lt" => Date.new(2016,1,1)}).expand_filter_criteria
#qs.filter_to_shop.filter_to_active.with_effective_date({"$gt" => Date.new(2015,10,15), "$lt" => Date.new(2016,1,1)}).eliminate_family_duplicates

qs.evaluate.each do |r|
#  if r['enrollment_kind'] != "open_enrollment"
    puts r['hbx_id']
#  end
end

#raise cf_plan_ids.count.inspect
=begin
qs.add({
  "$match" => {
      "plan_id" => {"$ne" => nil},
      "aasm_state" => { "$nin" => [
         "coverage_canceled", "coverage_terminated", "renewing_waived", "inactive"
      ]}
  }
})

#qs.purchased_on_grouping.each do |rec|
#  puts rec.join(" - ")
#end

qs.evaluate.each do |r|
  if r['policy_purchased_at'] > Time.new(2015,12,19,0,0,0,"-05:00")
    puts r['hbx_id']
  end
end
qs.add({
  "$match" => {
    "$or" => [
      {"plan_id" => {"$ne" => nil},
        "aasm_state" => { "$in" => [
         "coverage_canceled", "coverage_terminated", "renewing_waived"
      ]}},
      {
        "aasm_state" => "inactive"
      }]
  }
})
# qs.add({
#  "$match" => {
#    "family_created_at" => {"$lt" => Time.new(2015,11,1,14,0,0)}
#  }
# })
family_ids = qs.evaluate.map do |r|
  r['_id']['family_id']
end

CSV.open("congressional_terminations.csv", "w") do |csv|
  csv << ["hbx_id", "first_name", "last_name"]
  Family.where("id" => {"$in" => family_ids}).each do |fam|
    person = fam.primary_applicant.person
    csv << [person.hbx_id, person.first_name, person.last_name]
  end
end

def safe_compare(val1, val2)
  val1_safe = val1.blank? ? "" : val1.strip.downcase 
  val2_safe = val2.blank? ? "" : val2.strip.downcase 
  !(val1_safe == val2_safe)
end

def address_different?(address1, address2)
  return false if address1.nil?
  return false if address2.nil?
  safe_compare(address1.address_1, address2.address_1) ||
    safe_compare(address1.address_2, address2.address_2) ||
    safe_compare(address1.address_3, address2.address_3) ||
    safe_compare(address1.city, address2.city) ||
    safe_compare(address1.state, address2.state) ||
    safe_compare(address1.zip, address2.zip)
end

def names_changed?(person1, person2)
  return false if person1.nil?
  return false if person2.nil?
  safe_compare(person1.name_pfx, person2.name_pfx) ||
    safe_compare(person1.name_sfx, person2.name_sfx) ||
    safe_compare(person1.first_name, person2.first_name) ||
    safe_compare(person1.middle_name, person2.middle_name) ||
    safe_compare(person1.last_name, person2.last_name)
end

def person_names_changed?(person)
  first_person = person
  other_versions = person.versions
  comparable_people = [first_person] + person.versions
  comparisons = comparable_people.combination(2)
  comparisons.any? do |peeps|
    names_changed?(peeps.first, peeps.last)
  end
end

qs.evaluate.each do |r|
  puts r['hbx_id']
end

people_ids = []
Family.where("id" => {"$in" => family_ids}).each do |fam|
  people_ids << fam.primary_applicant.person_id
end
people = Person.where(
  "id" => {"$in" => people_ids},
  "addresses" => {
    "$elemMatch" => {
      "kind" => "home",
      "updated_at" => {"$gt" => Time.new(2015,11,30,0,0,0)}
    }
  }
)
people = Person.where(
  "id" => {"$in" => people_ids},
  "updated_at" => {"$gt" => Time.new(2015,11,30,0,0,0)}
)

def person_addresses_changed?(person)
  top_level_addresses = person.addresses.select { |a| a.kind == "home" }
  version_addresses = person.versions.flat_map(&:addresses).select { |a| a.kind == "home" }
  comparable_addresses = top_level_addresses + version_addresses
  comparisons = comparable_addresses.combination(2)
  comparisons.any? do |addys|
    address_different?(addys.first, addys.last)
  end
end
CSV.open("congressional_address_changes.csv", "w") do |csv|
  csv << ["hbx_id", "first_name", "last_name", "address_1", "address_2", "address_3", "city", "state", "zip"]
  people.each do |r|
    address = r.addresses.select { |a| a.kind == "home" }.sort_by { |a| a.updated_at }.last
    if person_addresses_changed?(r)
      csv << [r.hbx_id, r.first_name, r.last_name, address.address_1, address.address_2, address.address_3, address.city, address.state, address.zip]
    end
  end
end

CSV.open("congressional_name_changes.csv", "w") do |csv|
  csv << ["hbx_id", "name_pfx", "first_name", "middle_name", "last_name", "name_sfx"]
  people.each do |r|
    if person_names_changed?(r)
      csv << [r.hbx_id, r.name_pfx, r.first_name, r.middle_name, r.last_name, r.name_sfx]
    end
  end
end
=end
#qs.purchased_on_grouping.each do |rec|
#  puts rec.join(" - ")
#end

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

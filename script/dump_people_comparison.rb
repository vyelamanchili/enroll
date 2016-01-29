people = Person.all

CSV.open("enroll_people_comparison.csv", "w") do |csv|
  csv << ["hbx_id", "first_name", "last_name", "dob", "ssn", "comparison_hash"]
  people.each do |person|
    f_name_str = person.first_name.strip.downcase
    l_name_str = person.last_name.strip.downcase
    dob_str = person.dob.blank? ? "" : person.dob.strftime("%Y%m%d")
    comparison_hash = Digest::SHA256.hexdigest(dob_str + f_name_str + l_name_str)
    csv << [person.hbx_id, person.first_name, person.last_name, dob_str, person.ssn, comparison_hash]
  end
end

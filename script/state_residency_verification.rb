#datafix for consumer with state residency failed but ssn and citizenship/immigration status successful

people = Person.where("consumer_role" => {"$exists" => true, "$ne" => nil},
             "consumer_role.aasm_state" => "verifications_outstanding",
             "consumer_role.lawful_presence_determination.aasm_state" => "verification_successful",
             "consumer_role.is_state_resident" => false)

people.each do |person|
  person.consumer_role.authorize_residency! verification_attr
  person.consumer_role.authorize_lawful_presence! verification_attr
end

def verification_attr
  OpenStruct.new({:verified_at => Time.now,
                  :authority => "hbx"
                 })
end




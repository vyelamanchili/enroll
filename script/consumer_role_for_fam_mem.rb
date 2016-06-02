#fam1=Family.all_with_multiple_family_members.limit(9155); nil
#fam2=Family.all_with_multiple_family_members.offset(9156); nil

families=Family.all_with_multiple_family_members

broken_family=Family.find("566ebebcfaca145b8900000c")

families.each do |family|
  unless family == broken_family do
    if family.primary_applicant.person.consumer_role
      family.family_members.each do |family_member|
        begin
          person = family_member
          dob = person.dob
          gender = person.gender
          is_applicant = person.is_applicant
          consumer_role = ConsumerRole.new(:dob => dob, :gender => gender, :is_applicant => is_applicant )
          person.consumer_role = consumer_role
          person.save!
        rescue => e
          puts "This person #{person.id} can't be updated. Error #{e.message}"
        end
      end
    end
  end
  end
end

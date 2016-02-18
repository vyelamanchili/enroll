FactoryGirl.define do
  factory :family do
    person
    sequence(:e_case_id) {|n| "#{Faker::Number.hexadecimal(10)}#{n}"}
    renewal_consent_through_year  2017
    submitted_at Time.now
    updated_at "user"
    family_members factory: :family_member
    
    # trait :with_primary_family_member do
    #   family_members { [FactoryGirl.build(:family_member, family: self, is_primary_applicant: true)] }
    # end
  end
end

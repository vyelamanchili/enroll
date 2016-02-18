FactoryGirl.define do
  factory :family_member do
    person
    association :family
    is_primary_applicant true
    is_coverage_applicant true

    # trait :primary do
    #   is_primary_applicant true
    # end
  end
end

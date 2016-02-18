FactoryGirl.define do
  factory :person do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    gender ['male', 'female'].shuffle.sample(1).first
    dob Faker::Time.backward(10950).to_date #up to 30 years ago
    is_active true
    # The user possibly gets associated by the enrollment_factory. Use the consumer_role_for(user) method to achieve building the user with a consumer role and associating with a user.

   #  after(:create) do |p, evaluator|
  #     create_list(:address, 2, person: p)
  #     create_list(:phone, 2, person: p)
  #     create_list(:email, 2, person: p)
  #     #create_list(:employee_role, 1, person: p)
  #   end
  #
  #   trait :without_first_name do
  #     first_name ' '
  #   end
  #
  #   trait :without_last_name do
  #     last_name ' '
  #   end
  #
  #   factory :invalid_person, traits: [:without_first_name, :without_last_name]
  #
  #   trait :male do
  #     gender "male"
  #   end
  #
  #   trait :female do
  #     gender "female"
  #   end
  #
  #   trait :with_employee_role do
  #     after(:create) do |p, evaluator|
  #       create_list(:employee_role, 1, person: p)
  #     end
  #   end
  #
  #   trait :with_employer_staff_role do
  #     after(:create) do |p, evaluator|
  #       create_list(:employer_staff_role, 1, person: p)
  #     end
  #   end
  #
  #   trait :with_hbx_staff_role do
  #     after(:create) do |p, evaluator|
  #       create_list(:hbx_staff_role, 1, person: p)
  #     end
  #   end
  #
  #   trait :with_broker_role do
  #     after(:create) do |p, evaluator|
  #       create_list(:broker_role, 1, person: p)
  #     end
  #   end
  #
  #   trait :with_consumer_role do
  #     after(:create) do |p, evaluator|
  #       create_list(:consumer_role, 1, person: p)
  #     end
  #   end
  #
  #   trait :with_assister_role do
  #     after(:create) do |p, evaluator|
  #       create_list(:assister_role, 1, person: p)
  #     end
  #   end
  #
  #   trait :with_csr_role do
  #     after(:create) do |p, evaluator|
  #       create_list(:assister_role, 1, person: p)
  #     end
  #   end
  #
  #   factory :male, traits: [:male]
  #   factory :female, traits: [:female]
  end
end

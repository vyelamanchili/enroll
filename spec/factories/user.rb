FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "#{Faker::Internet.email}#{n}"}
    gen_pass = User.generate_valid_password
    password gen_pass
    password_confirmation gen_pass
    authentication_token Faker::Number.hexadecimal(20)
    approved true
    roles ['web_service']
    
    # Trait to create person and family through the enrollment factory
    trait :with_consumer_role do
      after(:create) { |user| consumer_role_for(user) }
    end
  end

  # trait :without_email do
  #   email ' '
  # end
  #
  # trait :without_password do
  #   password ' '
  # end
  #
  # trait :without_password_confirmation do
  #   password_confirmation ' '
  # end
  #
  # trait :hbx_staff do
  #   roles ["hbx_staff"]
  # end
  #
  # trait :consumer do
  #   roles ["consumer"]
  # end
  #
  # trait "assister" do
  #   roles ["assister"]
  # end
  #
  # trait "csr" do
  #   roles ["csr"]
  # end
  #
  # trait "employee" do
  #   roles ["employee"]
  # end
  #
  # trait :employer_staff do
  #   roles ["employer_staff"]
  # end
  #
  # trait "broker" do
  #   roles ["broker"]
  # end
  #
  # trait "broker_agency_staff" do
  #   roles ["broker_agency_staff"]
  # end
  #
  # factory :invalid_user, traits: [:without_email, :without_password, :without_password_confirmation]
end

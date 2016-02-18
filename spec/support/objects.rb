# Quick methods for building custom factories.

def user
  @user ||= FactoryGirl.create :user
end

def person
  @person ||= FactoryGirl.create :person
end

def consumer_role_for(user)
  @consumer_role ||= Factories::EnrollmentFactory.construct_consumer_role(person_params, user)
end

def person_params
  {
    addresses: [],
    phones: [],
    emails: [],
    person: person.attributes.merge('ssn' => "#{Faker::Number.number(3)}-#{Faker::Number.number(2)}-#{Faker::Number.number(4)}")
  }
end
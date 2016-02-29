# Quick methods for building custom factories.

def user
  @user ||= create :user
end

def user_with_consumer_role
  @user ||= create :user, :with_consumer_role
end

def person
  @person ||= create :person
end

def build_person
  create :person, first_name: Forgery(:name).first_name, last_name: Forgery(:name).last_name
end


def consumer_role_for(usr)
  @consumer_role ||= Factories::EnrollmentFactory.construct_consumer_role(person_params, usr)
end

def person_params
  {
    addresses: [],
    phones: [],
    emails: [],
    person: build_person.attributes.merge(
        'ssn' => "#{Forgery(:russian_tax).bik.first(3)}-#{Forgery(:russian_tax).bik.first(2)}-#{Forgery(:russian_tax).bik.first(4)}"
    )
  }
end

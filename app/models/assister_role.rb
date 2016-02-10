class AssisterRole
  include Mongoid::Document
  include SetCurrentUser
  include Mongoid::Timestamps

  embedded_in :person

  delegate :hbx_id, :hbx_id=, to: :person, allow_nil: true

  accepts_nested_attributes_for :person
  field :organization, type: String
  field :asked_for_help, type: Array, default: []

  def parent
    person
  end

  def ask_for_help person_id
    asked_for_help.append(person_id) unless asked_for_help.include?(person_id)
    self.save
  end

  def allowed_to_access person_id
    asked_for_help.include?(person_id)
  end  

  class << self
    
    def find(id)
      return nil if id.blank?
      people = Person.where("assister_role._id" => BSON::ObjectId.from_string(id))
      people.any? ? people[0].assister_role : nil
    end

    def list_assisters(person_list)
      person_list.reduce([]) { |assisters, person| assisters << person.assister_role }
    end

    def all
      list_assisters(Person.where(assister_role: {:$exists => true}))
    end

    def first
      all.first
    end

    def last
      all.last
    end

  end  

end

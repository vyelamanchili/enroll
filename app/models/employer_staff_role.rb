class EmployerStaffRole
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :person

  field :is_owner, type: Boolean, default: false
  field :is_active, type: Boolean, default: true
  field :employer_profile_id, type: BSON::ObjectId
  field :bookmark_url, type: String
  validates_presence_of :employer_profile_id

  def self.find(id)
    person = Person.where(:'employer_staff_roles._id' => id ).first
    employer_staff_role = person.employer_staff_roles.detect{|role| role._id == id}
  end

end

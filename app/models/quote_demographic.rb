class QuoteDemographic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :market, type: String, default: "Profession"
  field :average_household_size, type: Float
  field :age_from, type: Integer
  field :age_to, type: Integer



  def generate_random_age
    rand(age_from..age_to)
  end

end

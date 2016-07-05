class QuoteHousehold
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidSupport::AssociationProxies

  embedded_in :quote
  embeds_many :quote_members

  field :family_id, type: String

  # Quote Benefit Group ID for this employee on the roster
  field :quote_benefit_group_id, type: BSON::ObjectId

  validates_uniqueness_of :family_id

  before_save :assign_benefit_group_id

  accepts_nested_attributes_for :quote_members

  def employee?
    quote_members.where("employee_relationship" => "employee").count == 1 ? true : false
  end

  def spouse?
    quote_members.where("employee_relationship" => "spouse").count == 1 ? true : false
  end

  def children?
    quote_members.where("employee_relationship" => "child_under_26").count > 1 ? true : false
  end

  def employee
    quote_members.where("employee_relationship" => "employee").first
  end

  def assign_benefit_group_id
    puts "Assigining Benefit Group IDs"
    if quote_benefit_group_id.nil?
      puts "quote.quote_benefit_groups.first.id: " + quote.quote_benefit_groups.first.id.to_s
      self.quote_benefit_group_id = quote.quote_benefit_groups.first.id
      puts "quote_benefit_group_id " + quote_benefit_group_id.to_s
    end
  end

end

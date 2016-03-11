class HealthAssessment
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :health_ratable, polymorphic: true

  OVERALL_HEALTH_KINDS = %w(poor fair good very\ good excellent)

  HEALTH_CONDITION_KINDS = %w(asthma arthritis back\ problems breast\ cancer diabetes 
                              heart\ disease high\ blood\ pressure high\ cholesterol 
                              lung\ cancer prostate\ cancer pregnant\ or\ planning\ pregnancy)


  field :overall_health, type: String
  field :health_conditions, type: Array, default: []

end

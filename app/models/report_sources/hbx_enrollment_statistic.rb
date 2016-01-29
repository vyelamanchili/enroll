module ReportSources
  class HbxEnrollmentStatistic
    include Mongoid::Document

    field :policy_start_on, type: DateTime
    field :family_created_at, type: DateTime
    field :policy_purchased_at, type: DateTime
    field :plan_id, type: BSON::ObjectId
    field :hbx_id, type: String
    field :enrollment_kind, type: String
    field :aasm_state, type: String
    field :coverage_kind, type: String
    field :family_id, type: BSON::ObjectId
    field :rp_ids, type: Array
    field :consumer_role_id, type: Array
    field :benefit_group_id, type: Array
    field :benefit_group_assignment_id, type: Array
    field :state_transitions, type: Array


    def self.populate_historic_data!
      q = Queries::PolicyAggregationPipeline.new
      q.denormalize
      q.evaluate.each
    end

    def self.populate_time_dimensions!
      self.all.each do |rec|
        rec.populate_applicable_dimensions!
      end
    end

    def populate_applicable_dimensions!
      eligible_dimensions.each_pair do |k, v|
        ::Analytics::AggregateEvent.increment_time(topic: k, moment: self.send(v))
      end
    end

    def eligible_dimensions
      dimensions = {}
      topic_specifications.each do |ts|
        if self.send(ts.last)
          dimensions[ts.first + " - Submitted At"] = :policy_purchased_at
          dimensions[ts.first + " - Effective Date"] = :policy_start_on
        end
      end
      dimensions
    end

    def topic_specifications
      [
        ["SHOP Enrollment", :shop_purchase?],
        ["IVL Enrollment", :ivl_purchase?],
        ["SHOP Renewal", :shop_renewal?],
        ["IVL Renewal", :ivl_renewal?]
      ]
    end

    def shop_purchase?
      completed_shopping? && (consumer_role_id.blank?)
    end

    def shop_renewal?
      shop_purchase? && renewal?
    end

    def ivl_renewal?
      ivl_purchase? && renewal?
    end

    def ivl_purchase?
      completed_shopping? && (!consumer_role_id.blank?)
    end

    def health?
      coverage_kind == "health"
    end

    def renewal?
      (HbxEnrollment::RENEWAL_STATUSES & state_transitions).any?
    end

    def completed_shopping?
      !["shopping", "inactive"].include?(:aasm_state)
    end
  end
end

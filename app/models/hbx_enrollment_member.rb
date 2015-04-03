class HbxEnrollmentMember
  include Mongoid::Document
  include Mongoid::Timestamps
  include BelongsToFamilyMember

  embedded_in :hbx_enrollment

  field :applicant_id, type: BSON::ObjectId
  field :carrier_member_id, type: String
  field :is_subscriber, type: Boolean, default: false

  field :premium_amount, type: Money

  field :eligibility_date, type: Date
  field :coverage_start_on, type: Date
  field :coverage_end_on, type: Date

  validates_presence_of :applicant_id, :is_subscriber, :eligibility_date, :premium_amount,
    :coverage_start_on

  validate :end_date_gt_start_date

  def family
    return nil unless hbx_enrollment
    hbx_enrollment.family
  end

  def age_on_effective_date(dob)
    return unless @coverage_start_on.present?
    age = @coverage_start_on.year - dob.year

    # Shave off one year if coverage starts before birthday
    if @coverage_start_on.month == dob.month
      age -= 1 if @coverage_start_on.day < dob.day
    else
      age -= 1 if @coverage_start_on.month < dob.month
    end

    age
  end

  def is_subscriber?
    self.is_subscriber
  end

private

  def end_date_gt_start_date
    return unless coverage_end_on.present?
    if end_date < start_date
      self.errors.add(:coverage_end_on, "Coverage start date must preceed or equal end date")
    end
  end



end

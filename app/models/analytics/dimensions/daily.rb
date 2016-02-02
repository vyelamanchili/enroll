module Analytics
  module Dimensions
    class Daily
      include Mongoid::Document

      # attr_accessor :subject, :title

      field :subject,   type: String
      field :date,      type: Date
      field :title,     type: String
      field :format,    type: String

      field :week_day,  type: Integer

      index({subject: 1, date: 1, :"hours_of_day.hour" => 1})
      index({subject: 1, week_day: 1})

      embeds_one  :metadata,         class_name: "Document", as: :documentable
      embeds_one  :hours_of_day,     class_name: "Analytics::Dimensions::HoursOfDay"
      embeds_many :minutes_of_hours, class_name: "Analytics::Dimensions::MinutesOfHour"

      accepts_nested_attributes_for :metadata, :hours_of_day, :minutes_of_hours

      after_save :update_metadata

      validates_presence_of :subject, :date, :week_day

      # def initialize(site: nil, subject: nil, date: nil)
      def initialize(options={})
        super
        pre_allocate_document

        defaults = {
                      date:   TimeKeeper.date_of_record,
                      format: "text/plain; charset=us-ascii"
                    }

        options = defaults.merge(options)
        options.each_pair { |k,v| write_attribute(k, v) }
      end

      def increment(new_time)
        hour    = new_time.hour
        minute  = new_time.min

        hours_of_day.inc(("h" + hour.to_s).to_sym => 1)
        minutes_of_hours.where("hour" => hour.to_s).first.inc(("m" + minute.to_s).to_sym => 1)
        self
      end

      def date=(new_date)
        write_attribute(:date, new_date)
        write_attribute(:week_day, new_date.wday)
      end

      def self.options
        (0..23).map do |k|
          "h#{k}"
        end
      end

      def sum
        (0..23).map do |k|
          hours_of_day.public_send("h#{k}")
        end
      end

      def amount
        (0..23).reduce(0) do |sum, k|
          sum + hours_of_day.public_send("h#{k}")
        end
      end

      def amount_for_drilldown
        (0..23).map do |k|
          ["h#{k}", hours_of_day.public_send("h#{k}")]
        end
      end

    private
      def pre_allocate_document
        self.build_metadata unless metadata.present?
        self.build_hours_of_day unless hours_of_day.present?

        if minutes_of_hours.size == 0 
          (0..23).map { |i| self.minutes_of_hours << Analytics::Dimensions::MinutesOfHour.new(hour: i) }
        end
      end

      def update_metadata
        metadata.subject  = subject
        metadata.date     = date
        metadata.title    = title if title.present?
        metadata.format   = format
      end

    end
  end
end

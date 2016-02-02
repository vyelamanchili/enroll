module Analytics
  class Dimensions::Weekly
    include Mongoid::Document

      field :subject,   type: String
      field :date,      type: Date
      field :title,     type: String
      field :format,    type: String

      field :week,  type: Integer
      field :year,  type: Integer

      field :d1, type: Integer, default: 0
      field :d2, type: Integer, default: 0
      field :d3, type: Integer, default: 0
      field :d4, type: Integer, default: 0
      field :d5, type: Integer, default: 0
      field :d6, type: Integer, default: 0
      field :d7, type: Integer, default: 0

      index({subject: 1, week: 1, year: 1})
      index({subject: 1, date: 1})

      embeds_one  :metadata, class_name: "Document", as: :documentable

      validates_presence_of :subject, :date, :week, :year

      after_save :update_metadata

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

      def increment(new_date)
        week_day  = new_date.wday

        # Use the Mongoid increment (inc) function
        inc(("d" + week_day.to_s).to_sym => 1)
        self
      end

      def sum
        (1..7).map { |i| eval("d" + i.to_s) }
      end

      def self.options
        (1..7).map do |k|
          "d#{k}"
        end
      end

      def amount_for_drilldown
        (1..7).map do |k|
          ["d#{k}", self.public_send("d#{k}")]
        end
      end

      def amount
        (1..7).reduce(0) do |sum, k|
          sum + self.public_send("d#{k}")
        end
      end

    private
      def pre_allocate_document
        self.build_metadata unless metadata.present?

        if week.blank?
          binding.pry
          if date.is_a? Time
            self.week = date.to_datetime.cweek
          else
            self.week = date.cweek
          end
        end

        if year.blank?
          self.year = date.year
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

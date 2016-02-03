module Analytics

  class AggregateEvent

    # accepts_nested_attributes_for :days_of_month, :hours_of_day

    AVERAGE_EVENTS_PER_DAY = 50
    DCHBX_EPOCH = Date.new(2015,10,12).beginning_of_day

    def probabaliistic_preallocate?
      probability = 1.0 / AVERAGE_EVENTS_PER_DAY
      rand(0.0..1.0) < probability
    end

    ## Highchart DSL
    # chart: {type: "bar"},
    # title: {text: "taxonomy"},
    # xAxis: {categories: ['kingdom', 'phylum', 'class', 'order', 'genus', 'species']},
    # yAxis: {title: {text: 'Biology'}},
    # series: [{name: "foo", data: [0, 1, 2]}, {name: "bar", data: [7, 8, 9]}]


    def self.subjects_count_daily(subject: nil, begin_on: nil, end_on: nil)

      # Calling without arguments will return all subjects for entire time period
      subjects  ||= []
      begin_on  ||= DCHBX_EPOCH
      end_on    ||= TimeKeeper.date_of_record.end_of_day

      if subjects.size == 0
        criteria = Analytics::Dimensions::Daily.where(:date.gte => begin_on).
                                                  and(:date.lte => end_on).
                                                  sort(date: 1)
      else
        criteria = Analytics::Dimensions::Daily.any_in(:"subject" => subjects).
                                                  and(:date.gte => begin_on).
                                                  and(:date.lte => end_on).
                                                  sort(:date => 1)
      end
    end


    def self.subjects_count_weekly(subjects: nil, begin_on: nil, end_on: nil)

      # Calling without arguments will return all subjects for entire time period
      subjects  ||= []
      begin_on  ||= DCHBX_EPOCH
      end_on    ||= TimeKeeper.date_of_record.end_of_day

      if subjects.size == 0
        criteria = Analytics::Dimensions::Weekly.where(:date.gte => begin_on).
                                                  and(:date.lte => end_on).
                                                  sort(date: 1)
      else
        criteria = Analytics::Dimensions::Weekly.any_in(:"subject" => subjects).
                                                  and(:date.gte => begin_on).
                                                  and(:date.lte => end_on).
                                                  sort(:date => 1)
      end

      criteria.to_a
    end

    def self.subjects_count_monthly(subject: nil, begin_on: nil, end_on: nil)
      # Calling without arguments will return all subjects for entire time period
      subjects  ||= []
      begin_on  ||= DCHBX_EPOCH
      end_on    ||= TimeKeeper.date_of_record.end_of_day

      if subjects.size == 0
        criteria = Analytics::Dimensions::Monthly.where(:date.gte => begin_on).
                                                  and(:date.lte => end_on).
                                                  sort(date: 1)
      else
        criteria = Analytics::Dimensions::Monthly.any_in(:"subject" => subjects).
                                                  and(:date.gte => begin_on).
                                                  and(:date.lte => end_on).
                                                  sort(:date => 1)
      end

      criteria.to_a
    end

    def self.increment_time(subject: nil, moment: TimeKeeper.datetime_of_record)
      month     = moment.month
      week      = moment.to_date.cweek
      year      = moment.to_date.year

      raise ArgumentError.new("missing value: subject, expected as keyword ") if subject.blank?

      # Update daily stats
      daily_docs = Analytics::Dimensions::Daily.where(subject: subject, date: moment)

      if daily_docs.size == 0
        daily_instance = Analytics::Dimensions::Daily.new(subject: subject, date: moment)
      else
        daily_instance = daily_docs.first
      end

      # Update weekly stats
      weekly_docs = Analytics::Dimensions::Weekly.where(subject: subject, week: week, year: year)
      if weekly_docs.size == 0
        weekly_instance = Analytics::Dimensions::Weekly.new(subject: subject, week: week, year: year, date: moment)
      else
        weekly_instance = weekly_docs.first
      end

      # Update monthly stats
      monthly_docs = Analytics::Dimensions::Monthly.where(subject: subject, month: month, year: year)
      if monthly_docs.size == 0
        monthly_instance = Analytics::Dimensions::Monthly.new(subject: subject, month: month, year: year, date: moment)
      else
        monthly_instance = monthly_docs.first
      end

      daily_instance.increment(moment)
      weekly_instance.increment(moment)
      monthly_instance.increment(moment)

      if daily_instance.save && weekly_instance.save && monthly_instance.save
        [daily_instance, weekly_instance, monthly_instance]
      else
        raise StandardError.new("update failed, unable to save one or more time dimensions " [daily_instance, weekly_instance, monthly_instance])
      end

    end

    # TODO
    def self.increment_geography(subject, site: "dchbx")
    end

  end
end

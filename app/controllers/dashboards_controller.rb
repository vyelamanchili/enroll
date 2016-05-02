class DashboardsController < ApplicationController
  layout "dashboard"

  def index
    # @begin_on = TimeKeeper.date_of_record.beginning_of_week
    @begin_on = TimeKeeper.date_of_record.last_month
    @title = "Week-to-date, starting: #{@begin_on.to_s}"

    subjects = ["IVL Enrollment - Submitted At", "SHOP Enrollment - Submitted At"]
    @reports  = Analytics::AggregateEvent.subjects_count_weekly(subjects: subjects, begin_on: @begin_on)

    @reports_for_chart = @reports.map {|r| {name: r.subject.split(/ - submitted at/i).first.humanize, y: r.amount}}
    @reports_for_drilldown_options = Analytics::Dimensions::Weekly.options
    @reports_for_drilldown = @reports.map {|r| {name: r.subject.split(/ - submitted at/i).first.humanize, data: r.sum}}
  end

  def stock
    @title = "#{Date.new(2015,11,1).to_s} - #{TimeKeeper.datetime_of_record.to_s}"
    subjects = ["IVL Enrollment - Submitted At", "SHOP Enrollment - Submitted At"]
    @reports  = Analytics::AggregateEvent.subjects_count_monthly(subjects: subjects, begin_on: @begin_on)
    @reports_for_stock = group_by_subject(@reports)
  end

  def report
    @type = params[:type]
    if params[:begin_on].present? and params[:end_on].present?
      #without 1d 1w,  always select end and start
      begin_on = DateTime.strptime(params[:begin_on], '%m/%d/%Y').to_date
      end_on = DateTime.strptime(params[:end_on], '%m/%d/%Y').to_date
      range = (end_on - begin_on).to_i
      case 
      when range == 0
        @type = 'Day'
      when range <= 6
        @type = 'Week'
      when (range > 7 && range < 31)
        @type = 'Month'
      when range > 30
        @type = 'Year'
      end
    elsif params[:type].present?
      @type = params[:type]
      case @type
      when 'Day'
        begin_on = TimeKeeper.date_of_record.beginning_of_day
      when 'Week'
        begin_on = TimeKeeper.date_of_record.beginning_of_week
      when 'Month'
        begin_on = TimeKeeper.date_of_record.beginning_of_month
      when 'Year'
        begin_on = TimeKeeper.date_of_record.beginning_of_year
      end
      end_on = TimeKeeper.date_of_record.end_of_day
    end

    case @type
    when 'Day'
      @reports = Analytics::AggregateEvent.subjects_count_daily(begin_on: begin_on, end_on: end_on)
      @title = "Today (#{begin_on.to_s})"
      @reports_for_drilldown_options = Analytics::Dimensions::Daily.options
    when 'Week'
      @reports = Analytics::AggregateEvent.subjects_count_weekly(begin_on: begin_on, end_on: end_on)
      @title = "#{TimeKeeper.date_of_record.beginning_of_week.to_s} - #{TimeKeeper.datetime_of_record.to_s}"
      @reports_for_drilldown_options = Analytics::Dimensions::Weekly.options
    when 'Month'
      @reports = Analytics::AggregateEvent.subjects_count_monthly(begin_on: begin_on, end_on: end_on)
      @reports_for_drilldown_options = Analytics::Dimensions::Monthly.options
    when 'Year'
      @reports = Analytics::AggregateEvent.subjects_count_monthly(begin_on: begin_on, end_on: end_on)
      @reports_for_chart = group_by_subject_for_year(@reports)
      @reports_for_drilldown = group_by_month_for_year(@reports)
      @reports_for_drilldown_options = @reports.map{|r| "#{r.year}-#{r.month}"}.uniq
    end

    @title ||= "#{begin_on.to_s} - #{end_on.to_s}"
    @begin_on = begin_on
    @reports_for_chart ||= @reports.map {|r| {name: r.subject.humanize, y: r.amount}}
    @reports_for_drilldown ||= @reports.map {|r| {name: r.subject.humanize, data: r.sum}}
  end

  def drilldown
    if params[:date].length > 5
      year,month = params[:date].split('-')
      @begin_on = params[:current]
      @reports = Analytics::Dimensions::Monthly.where(year: year, month: month).to_a
      @title = params[:date]
      @reports_for_drilldown_options = Analytics::Dimensions::Monthly.options
    elsif params[:date].present? and params[:date].start_with?("d")
      day = params[:date].gsub('d', '').to_i rescue 1
      current = DateTime.strptime(params[:current], '%m/%d/%Y').to_date
      if current == current.beginning_of_month
        begin_on = current.beginning_of_month + (day - 1).days
      else
        begin_on = current.beginning_of_week + (day - 1).days
      end
      end_on = begin_on.end_of_day
      @begin_on = begin_on
      @reports = Analytics::AggregateEvent.subjects_count_daily(begin_on: begin_on, end_on: end_on)
      @title = begin_on.to_s
      @reports_for_drilldown_options = Analytics::Dimensions::Daily.options
    else
      return
    end
    @reports_for_chart = @reports.map {|r| {name: r.subject.humanize, y: r.amount}}
    @reports_for_drilldown = @reports.map {|r| {name: r.subject.humanize, data: r.sum}}
  end

  def live
  end

  def data_for_live
    render json: [TimeKeeper.datetime_of_record.to_i*1000, rand(10)]
  end

  def group_by_subject_for_year(reports)
    subjects = reports.map(&:subject).uniq
    subjects.map do |subject|
      {name: subject.humanize,
       y: reports.select{|r| r.subject == subject}.sum(&:amount)}
    end
  end

  def group_by_month_for_year(reports)
    subjects = reports.map(&:subject).uniq
    subjects.map do |subject|
      {name: subject.humanize,
       data: reports.select{|r| r.subject == subject}.map(&:amount)}
    end
  end

  def group_by_subject(reports)
    subjects = reports.map(&:subject).uniq
    subjects.map do |subject|
      {name: subject.humanize,
       type: 'column',
       data: reports.select {|r|r.subject == subject}.map(&:sum_for_stock).flatten(1)
      }
    end
  end
end

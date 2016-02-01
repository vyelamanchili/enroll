class DashboardsController < ApplicationController
  layout "dashboard"

  def index
    @start_on = Date.new(2015,11,1).beginning_of_day
    @reports = Analytics::AggregateEvent.topic_count_weekly(start_on: @start_on)
    @title = "#{@start_on.to_s} - #{TimeKeeper.datetime_of_record.to_s}"

    @reports = Analytics::AggregateEvent.topic_count_monthly(start_on: @start_on)
    @reports_for_chart = group_by_topic_for_year(@reports)
    @reports_for_drilldown = group_by_month_for_year(@reports)
    @reports_for_drilldown_options = @reports.map{|r| "#{r.year}-#{r.month}"}.uniq
  end

  def stock
    @title = "#{Date.new(2015,11,1).to_s} - #{TimeKeeper.datetime_of_record.to_s}"
    @reports = Analytics::AggregateEvent.topic_count_monthly
    @reports_for_stock = group_by_topic(@reports)
  end

  def report
    @type = params[:type]
    if params[:start_on].present? and params[:end_on].present?
      #without 1d 1w,  always select end and start
      start_on = DateTime.strptime(params[:start_on], '%m/%d/%Y').to_date
      end_on = DateTime.strptime(params[:end_on], '%m/%d/%Y').to_date
      range = (end_on - start_on).to_i
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
        start_on = TimeKeeper.date_of_record.beginning_of_day
      when 'Week'
        start_on = TimeKeeper.date_of_record.beginning_of_week
      when 'Month'
        start_on = TimeKeeper.date_of_record.beginning_of_month
      when 'Year'
        start_on = TimeKeeper.date_of_record.beginning_of_year
      end
      end_on = TimeKeeper.date_of_record.end_of_day
    end

    case @type
    when 'Day'
      @reports = Analytics::AggregateEvent.topic_count_daily(start_on: start_on, end_on: end_on)
      @title = "Today (#{start_on.to_s})"
      @reports_for_drilldown_options = Analytics::Dimensions::Daily.options
    when 'Week'
      @reports = Analytics::AggregateEvent.topic_count_weekly(start_on: start_on, end_on: end_on)
      @title = "#{TimeKeeper.date_of_record.beginning_of_week.to_s} - #{TimeKeeper.datetime_of_record.to_s}"
      @reports_for_drilldown_options = Analytics::Dimensions::Weekly.options
    when 'Month'
      @reports = Analytics::AggregateEvent.topic_count_monthly(start_on: start_on, end_on: end_on)
      @reports_for_drilldown_options = Analytics::Dimensions::Monthly.options
    when 'Year'
      @reports = Analytics::AggregateEvent.topic_count_monthly(start_on: start_on, end_on: end_on)
      @reports_for_chart = group_by_topic_for_year(@reports)
      @reports_for_drilldown = group_by_month_for_year(@reports)
      @reports_for_drilldown_options = @reports.map{|r| "#{r.year}-#{r.month}"}.uniq
    end

    @title ||= "#{start_on.to_s} - #{end_on.to_s}"
    @start_on = start_on
    @reports_for_chart ||= @reports.map {|r| {name: r.topic.humanize, y: r.amount}}
    @reports_for_drilldown ||= @reports.map {|r| {name: r.topic.humanize, data: r.sum}}
  end

  def drilldown
    if params[:date].length > 5
      year,month = params[:date].split('-')
      @start_on = params[:current]
      @reports = Analytics::Dimensions::Monthly.where(site: 'dchbx', year: year, month: month).to_a
      @title = params[:date]
      @reports_for_drilldown_options = Analytics::Dimensions::Monthly.options
    elsif params[:date].present? and params[:date].start_with?("d")
      day = params[:date].gsub('d', '').to_i rescue 1
      current = DateTime.strptime(params[:current], '%m/%d/%Y').to_date
      if current == current.beginning_of_month
        start_on = current.beginning_of_month + (day - 1).days
      else
        start_on = current.beginning_of_week + (day - 1).days
      end
      end_on = start_on.end_of_day
      @start_on = start_on
      @reports = Analytics::AggregateEvent.topic_count_daily(start_on: start_on, end_on: end_on)
      @title = start_on.to_s
      @reports_for_drilldown_options = Analytics::Dimensions::Daily.options
    else
      return
    end
    @reports_for_chart = @reports.map {|r| {name: r.topic.humanize, y: r.amount}}
    @reports_for_drilldown = @reports.map {|r| {name: r.topic.humanize, data: r.sum}}
  end

  def live
  end

  def data_for_live
    render json: [TimeKeeper.datetime_of_record.to_i*1000, rand(10)]
  end

  def group_by_topic_for_year(reports)
    topics = reports.map(&:topic).uniq
    topics.map do |topic|
      {name: topic.humanize,
       y: reports.select{|r| r.topic == topic}.sum(&:amount)}
    end
  end

  def group_by_month_for_year(reports)
    topics = reports.map(&:topic).uniq
    topics.map do |topic|
      {name: topic.humanize,
       data: reports.select{|r| r.topic == topic}.map(&:amount)}
    end
  end

  def group_by_topic(reports)
    topics = reports.map(&:topic).uniq
    topics.map do |topic|
      {name: topic.humanize,
       type: 'column',
       data: reports.select {|r|r.topic == topic}.map(&:sum_for_stock).flatten(1)
      }
    end
  end
end

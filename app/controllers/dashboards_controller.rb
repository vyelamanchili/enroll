class DashboardsController < ApplicationController
  layout "dashboard"

  def index
    @reports = Analytics::AggregateEvent.topic_count_weekly(start_on: TimeKeeper.date_of_record.beginning_of_week)
    @title = "#{TimeKeeper.date_of_record.beginning_of_week.to_s} - #{TimeKeeper.datetime_of_record.to_s}"
    @reports_for_chart = @reports.map {|r| {name: r.topic.humanize, y: r.amount, drilldown: r.topic.humanize}}
    @reports_for_drilldown = @reports.map {|r| {name: r.topic.humanize, id: r.topic.humanize, data: r.amount_for_drilldown}}
  end

  def report
    @type = params[:type] || 'Week'


    case @type
    when 'Day'
      @reports = Analytics::AggregateEvent.topic_count_daily(start_on: TimeKeeper.date_of_record.beginning_of_day)
      @title = "Today (#{TimeKeeper.date_of_record.to_s})"
    when 'Week'
      @reports = Analytics::AggregateEvent.topic_count_weekly(start_on: TimeKeeper.date_of_record.beginning_of_week)
      @title = "#{TimeKeeper.date_of_record.beginning_of_week.to_s} - #{TimeKeeper.datetime_of_record.to_s}"
    when 'Month'
      @reports = Analytics::AggregateEvent.topic_count_monthly(start_on: TimeKeeper.date_of_record.beginning_of_month)
      @title = "#{TimeKeeper.date_of_record.beginning_of_month.to_s} - #{TimeKeeper.datetime_of_record.to_s}"
    when 'Year'
      @reports = Analytics::AggregateEvent.topic_count_monthly(start_on: TimeKeeper.date_of_record.beginning_of_year)
      @title = "#{TimeKeeper.date_of_record.beginning_of_year.to_s} - #{TimeKeeper.datetime_of_record.to_s}"
    end




    if params[:start_on].present? and params[:end_on].present?
      #without 1d 1w,  always select end and start
      start_on = DateTime.strptime(params[:start_on], '%m/%d/%Y').to_date rescue 0
      end_on = DateTime.strptime(params[:end_on], '%m/%d/%Y').to_date rescue 6
      range = (end_on - start_on).to_i
      case 
      when range == 0
        @type = 'Day'
      when range <= 6
        @type = 'Week'
      when range > 7
        @type = 'Month'
      end

      case @type
      when 'Day'
        @reports = Analytics::AggregateEvent.topic_count_daily(start_on: start_on, end_on: end_on)
        @title = "Today (#{start_on.to_s})"
      when 'Week'
        @reports = Analytics::AggregateEvent.topic_count_weekly(start_on: start_on, end_on: end_on)
        @title = "#{start_on.to_s} - #{end_on.to_s}"
      when 'Month'
        @reports = Analytics::AggregateEvent.topic_count_monthly(start_on: start_on, end_on: end_on)
        @title = "#{start_on.to_s} - #{end_on.to_s}"
      end
    end




    @reports_for_chart = @reports.map {|r| {name: r.topic.humanize, y: r.amount, drilldown: r.topic.humanize}}
    @reports_for_drilldown = @reports.map {|r| {name: r.topic.humanize, id: r.topic.humanize, data: r.amount_for_drilldown}}
  end

  def live
  end

  def data_for_live
    render json: [TimeKeeper.datetime_of_record.to_i*1000, rand(10)]
  end
end

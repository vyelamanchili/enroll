class DashboardsController < ApplicationController
  layout "dashboard"

  def index
    @type = 'Day'
    @title = "Today (#{TimeKeeper.date_of_record.to_s})"
    @reports = Analytics::AggregateEvent.topic_count_daily(start_on: TimeKeeper.date_of_record.beginning_of_day)
    @reports_for_chart = @reports.map {|r| {name: r.topic.humanize, data: [r.amount]}}
  end

  def report
    @type = params[:type] || 'Day'
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
    @reports_for_chart = @reports.map {|r| {name: r.topic.humanize, data: [r.amount]}}
  end
end

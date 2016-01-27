class DashboardsController < ApplicationController
  layout "dashboard"

  def index
    @type = 'Day'
    @reports = Analytics::AggregateEvent.topic_count_daily(start_on: TimeKeeper.date_of_record.beginning_of_day)
    @reports_for_chart = @reports.map {|r| {name: r.topic, data: [r.amount]}}
  end

  def report
    @type = params[:type] || 'Day'
    case @type
    when 'Day'
      @reports = Analytics::AggregateEvent.topic_count_daily(start_on: TimeKeeper.date_of_record.beginning_of_day)
    when 'Week'
      @reports = Analytics::AggregateEvent.topic_count_weekly(start_on: TimeKeeper.date_of_record.beginning_of_week)
    when 'Month'
      @reports = Analytics::AggregateEvent.topic_count_monthly(start_on: TimeKeeper.date_of_record.beginning_of_month)
    when 'Year'
      @reports = Analytics::AggregateEvent.topic_count_monthly(start_on: TimeKeeper.date_of_record.beginning_of_year)
    end
    @reports_for_chart = @reports.map {|r| {name: r.topic, data: [r.amount]}}
  end
end

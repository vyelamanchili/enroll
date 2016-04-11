class Insured::HealthAnalyticsController < ApplicationController

  before_action :set_current_person, :set_family
  layout "health_analytics"

  def new

  end

  def health
    @hbx_enrollment = params[:id]
  end

  def estimate
    @hbx_enrollment = params[:id]
  end

private
  def set_family
    @family = @person.try(:primary_family)
  end

  def init_address_for_dependent
    if @dependent.same_with_primary == "true"
      @dependent.addresses = Address.new(kind: 'home')
    elsif @dependent.addresses.is_a? ActionController::Parameters
      @dependent.addresses = Address.new(@dependent.addresses.try(:permit!))
    end
  end
end

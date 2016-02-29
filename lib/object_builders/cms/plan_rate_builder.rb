class PlanRateBuilder

  def initialize(rates_data)
    @rates_data = rates_data
    @last_row = @rates_data.last_row
  end

  def run
    assign_headers
    @results = Hash.new{|results,k| results[k] = []}
    # (2..@last_row).each do |row_number|
    (278..280).each do |row_number|
    # (2..47).each do |row_number|
      @row = @rates_data.row(row_number)
      build_premium_tables
    end
    find_plan_and_create_premium_tables
  end

  def calculate_and_build_premium_tables_for_family_option
    (20..65).each do |age|
      @age = age
      @results[@row[@headers["PlanId"]]] << {
        age: age,
        cost: calculate_cost,
        start_on: @row[@headers["RateEffectiveDate"]],
        end_on: @row[@headers["RateExpirationDate"]],
      }
    end
  end

  def calculate_cost
    if @age == 20
      (@row[@headers["PrimarySubscriberAndOneDependent"]].to_f - @row[@headers["IndividualRate"]].to_f).round(2)
    else
      @row[@headers["IndividualRate"]].to_f
    end
  end

  def build_premium_tables
    if @row[@headers["Age"]] == "Family Option"
      calculate_and_build_premium_tables_for_family_option
    else
      @results[@row[@headers["PlanId"]]] << {
        age: assign_age,
        cost: @row[@headers["IndividualRate"]],
        start_on: @row[@headers["RateEffectiveDate"]],
        end_on: @row[@headers["RateExpirationDate"]],
      }
    end
  end

  def assign_age
    case(@row[@headers["Age"]])
    when "0-20"
      20
    when "65 and over"
      65
    else
      @row[@headers["Age"]]
    end
  end

  def assign_headers
    @headers = Hash.new
    @rates_data.row(1).each_with_index {|header,i|
      @headers[header] = i
    }
  end

  def find_plan_and_create_premium_tables
    @results.each do |plan_id, premium_tables|
      # @plans = Plan.where(hios_id: /#{plan_id}/, active_year: @row[@headers["RateEffectiveDate"]].to_date.year)
      @plans = Plan.where(hios_id: /#{plan_id}/, active_year: 2015)
      @plans.each do |plan|
        binding.pry
        plan.premium_tables = nil
        plan.premium_tables.create!(premium_tables.uniq)
        plan.minimum_age, plan.maximum_age = plan.premium_tables.map(&:age).minmax
        plan.save
      end
    end
  end
end

class PlanRateBuilder

  def initialize(file)
    @file = file
    @results = Hash.new{|results,k| results[k] = []}
  end

  def run
    count = 0
    CSV.foreach(@file,
                :headers => true,
                :header_converters => lambda { |h| h.underscore.to_sym }) do |row|
      @row = row
      next if @row[:state_code] != "NV"
      build_premium_tables
      count+=1
      puts "Imported #{count} records" if count % 2000== 0
    end
    puts "Imported #{count} records."
    find_plan_and_create_premium_tables
  end

  # def run
  #   binding.pry
  #   @results = Hash.new{|results,k| results[k] = []}
  #   binding.pry
  #   (@first_row..@last_row).each do |row_number|
  #     @row = @data.row(row_number)
  #     build_premium_tables
  #   end
  #   find_plan_and_create_premium_tables
  # end

  def calculate_and_build_premium_tables_for_family_option
    (20..65).each do |age|
      @age = age
      @results[@row[:plan_id]] << {
        age: age,
        cost: calculate_cost_for_family_option,
        start_on: @row[:rate_effective_date],
        end_on: @row[:rate_expiration_date],
      }
    end
  end

  def calculate_cost_for_family_option
    if @age == 20
      (@row[:primary_subscriber_and_one_dependent].to_f - @row[:individual_rate].to_f).round(2)
    else
      @row[:individual_rate].to_f
    end
  end

  def build_premium_tables
    if @row[:age] == "Family Option"
      calculate_and_build_premium_tables_for_family_option
    else
      @results[@row[:plan_id]] << {
        age: assign_age,
        cost: @row[:individual_rate],
        start_on: @row[:rate_effective_date],
        end_on: @row[:rate_expiration_date],
      }
    end
  end

  def assign_age
    case(@row[:age])
    when "0-20"
      20
    when "65 and over"
      65
    else
      @row[:age]
    end
  end

  def find_plan_and_create_premium_tables
    @results.each do |plan_id, premium_tables|
      # @plans = Plan.where(hios_id: /#{plan_id}/, active_year: @row[@headers["RateEffectiveDate"]].to_date.year)
      @plans = Plan.where(hios_id: /#{plan_id}/, active_year: 2015)
      @plans.each do |plan|
        plan.premium_tables = nil
        plan.premium_tables.create!(premium_tables.uniq)
        plan.minimum_age, plan.maximum_age = plan.premium_tables.map(&:age).minmax
        plan.save
      end
    end
  end
end

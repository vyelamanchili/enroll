class PlanCostDecoratorQuote < PlanCostDecorator


  def add_premiums(combined_family, reference_date)
    roster_premium = Hash.new{|h,k| h[k]=0.00}
    combined_family.keys.each {|member|
      age = combined_family[member]
      premium = Caches::PlanDetails.lookup_rate(__getobj__.id, reference_date, age) 
      roster_premium[member.employee_relationship] += premium 
   }
    roster_premium
  end

  def add_members(combined_family)
     members.each {|member|
       combined_family[member] = member.age_on(benefit_group.start_on) if large_family_factor(member) > 0.0 
     }
     
  end 

end
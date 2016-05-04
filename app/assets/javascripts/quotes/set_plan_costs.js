function set_plan_costs() {
    var plan_ids = Object.keys(window.roster_premiums)
    for(var i = 0; i< plan_ids.length; i++){
      premium = 0
      plan_id = plan_ids[i]
      premiums = window.roster_premiums[plan_ids[i]]
      kinds = Object.keys(premiums) 
      for (var j=0; j<kinds.length; j++) {
      	kind = kinds[j]
        premium = premium + premiums[kind] *  window.relationship_benefits[kind]

      }
     premium = Math.round(premium)/100.
     plan_button = "[value='" + plan_id + "']"
     window.plan_button = plan_button
     employee_cost_div = $(plan_button).parent().children()[1]
     $(employee_cost_div).html(Math.ceil(parseFloat(premium)))

    }

}
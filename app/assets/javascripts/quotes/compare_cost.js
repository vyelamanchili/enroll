function get_health_cost_comparison() {
  plans = selected_plans()
  quote_id=$('#quote').val()
  if(plans.length == 0) {
    alert('Please select one or more plans for comparison');
    return;
   }
  $.ajax({
    type: "GET",
    url: "/broker_agencies/quotes/health_cost_comparison",
    data: {plans: plans, quote: quote_id},
    success: function(response) {
      $('#plan_comparison_frame').html(response);
      load_quote_listeners();
    }
  })
}

function get_dental_cost_comparison() {
  plans = selected_plans()
  quote_id=$('#quote').val()
  if(plans.length == 0) {
    alert('Please select one or more plans for comparison');
    return;
   }  
  $.ajax({
    type: "GET",
    url: "/broker_agencies/quotes/dental_cost_comparison",
    data: {plans: plans, quote: quote_id},
    success: function(response) {
      $('#dental_plan_comparison_frame').html(response);

    }
  })
}
function load_quote_listeners() {
    $('.publish td').on('click',
       function(){
        td = $(this)
        quote_id=$('#quote').val()
        plan_id=td.parent().attr('id')
        elected=td.index()
        cost = td.html()
        $.ajax({
          type: "GET",
          url: "/broker_agencies/quotes/publish",
          data: {quote_id: quote_id, plan_id: plan_id, elected: elected, cost: cost},
          success: function(response){
            $('#publish-quote').html(response);
            open_quote();
            load_quote_listeners()
          }
        })


    })
}    
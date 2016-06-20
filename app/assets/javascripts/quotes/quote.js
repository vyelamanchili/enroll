function inject_quote(quote_id, plan_id, elected, cost) {
    $.ajax({
      type: "GET",
      url: "/broker_agencies/quotes/publish",
      data: {quote_id: quote_id, plan_id: plan_id, elected: elected, cost: cost},
      success: function(response){
        $('#publish-quote').html(response);
      }
    })    
}
function load_quote_listeners() {
    $('.publish td').on('click', function(){
        td = $(this)
        quote_id=$('#quote').val()
        plan_id=td.parent().attr('id')
        elected=td.index()
        cost = td.html()
        inject_quote(quote_id, plan_id, elected, cost)
        $.ajax({
          type: 'GET',
          data: {quote: quote_id},
          url: '/broker_agencies/quotes/get_quote_info.js'
        }).done(function(response){
          set_quote_toolbar(response['summary'])
        })
        open_quote()
    })
}
function set_quote_toolbar(summary) {
  $('#quote-name').html(summary['name'])
  $('#quote-status').html(summary['status'])
  $('#quote-plan-name').html(summary['plan_name'])
  $('#quote-dental-plan-name').html(summary['dental_plan_name'])
}
function quote_change(quote_id){
       if(quote_id == 'No quote'){return}
        $.ajax({
          type: 'GET',
          data: {quote: quote_id},
          url: '/broker_agencies/quotes/get_quote_info.js'
        }).done(function(response){
            window.relationship_benefits = response['relationship_benefits']
            window.roster_premiums = response['roster_premiums']
            turn_off_criteria()
            toggle_plans(response['criteria'])
            set_plan_costs()
            inject_quote(quote_id)
            page_load_listeners()
            set_quote_toolbar(response['summary'])
            slider_listeners()
            set_benefits()
        })
    }
function quote_listeners(){
    $('#quote').on('change', function() {
      quote_change($(this).val())
      $("#plan_comparison_frame").html('')
    })
    $('.view-published').on('click', function(){
      quote_change(this.id)
      open_quote()
    })
}
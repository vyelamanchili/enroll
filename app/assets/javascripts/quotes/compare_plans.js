 sort_plans = function(){
      var sort_by = $(this.parentNode).text();
      console.log('clicked', sort_by)
      var plans=[];
      $.each($('.btn.active input'), function(i,item){plans.push( $(item).attr("value"))})
      $.ajax({
        type: "GET",
        url: "/broker_agencies/quotes/plan_comparison",
        data: {plans: plans, sort_by: sort_by},
        success: function(response) {
          $('#plan_comparison_frame').html(response);
          compare_plans_listeners();
        }
      })
    }
compare_plans_listeners = function (){
    $('#compare_plans_table').dragtable({dragaccept: '.movable'});
    $('.cost_sort').on('click', sort_plans);
}
    
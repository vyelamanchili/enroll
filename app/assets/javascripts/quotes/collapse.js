function collapse_all(){
  //bootstrapslider labels will have zero width unless the sliders are initially visible before being hidden
  setTimeout(function(){
    $('[aria-controls="quote-mgmt"]').attr('aria-expanded', false)
    $('#quote-mgmt').removeClass('in')
    $('[aria-controls="feature-mgmt"]').attr('aria-expanded', false)
    $('#feature-mgmt').removeClass('in')
    $('[aria-controls="plan-selection-mgmt"]').attr('aria-expanded', false)
    $('#plan-selection-mgmt').removeClass('in')
    },0)
}


function open_quote() {


    $('[aria-controls="quote-mgmt"]').attr('aria-expanded', false)
    $('#quote-mgmt').removeClass('in')

    $('[aria-controls="plan-selection-mgmt"]').attr('aria-expanded', false)
    $('#plan-selection-mgmt').removeClass('in')


    $('[aria-controls="dental-plan-selection-mgmt"]').attr('aria-expanded', false)
    $('#dental-plan-selection-mgmt').removeClass('in')


    $('[aria-controls="publish-quote"]').attr('aria-expanded', true)
    $('#publish-quote').addClass('in')

}


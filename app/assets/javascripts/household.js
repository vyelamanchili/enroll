var Household = function() {

  function selectDoctor(event, item, $thisObj) {
    var $widget = $thisObj.closest('.doctors');
    var my_doctors = $widget.find('.my-doctors');
    my_doctors.prepend("<span class='my-doctor'><span>" + item.name + "<i class='fa fa-times' aria-hidden='true' title='Close' data-toggle='tooltip'></i></span></span>");
    $thisObj.find('.tt-dropdown-menu').css('display', 'none')
    $('[data-toggle="tooltip"]').tooltip();
    $thisObj.typeahead('val', '');
    my_doctors.find('.fa').on('click', function() {
      $(this).closest('.my-doctor').remove();
    })
  };

  function addMedications(thisObj) {
      modal_id = thisObj.attr('id');
      if ( thisObj.find('[placeholder="Add A Prescription Name"]:first').val().length > 0 ) {
        medication = thisObj.find('[placeholder="Add A Prescription Name"]:first').val();
        family_member = thisObj.closest('.family-member');
        if ( family_member.find('.medications .panel-body:first a span').length == 1 ) {
          family_member.find('.medications .panel-body').append(" and ");
          family_member.find('.medications .panel-body').append('<span>'+medication+'</span>');
        }
        else if ( thisObj.find('.medications .panel-body:first a span').length >= 2 ) {
          family_member.find(".medications .panel-body a:contains(' (Edit)')").remove();
          family_member.find('.medications .panel-body').append('<span>'+medication+'</span>');
          medications = family_member.find('.medications .panel-body:first').find('span').clone();
          family_member.find('.medications .panel-body').html("");
          $.each(medications, function (i, val) {
            if ( i == 0 ) {
              family_member.find('.medications .panel-body').append(val);
            }
            else if ( i+1 == medications.length ) {
              family_member.find('.medications .panel-body').append(", and ");
              family_member.find('.medications .panel-body').append(val);
            } else {
              family_member.find('.medications .panel-body').append(", ");
              family_member.find('.medications .panel-body').append(val);
            }
          });

        } else {
          family_member.find('.medications .panel-body').html("");
          family_member.find('.medications .panel-body').append('<span>'+medication+'</span>');
        }
        family_member.find(".medications .panel-body a:contains(' (Edit)')").remove();
        family_member.find('.medications .panel-body span').wrap("<a data-target=#"+modal_id+" data-toggle='modal'></a>")
        family_member.find('.medications .panel-body').append("<a data-target=#"+modal_id+" data-toggle='modal'> (Edit)</a>")

      }
      $('#'+modal_id+' input[type="text"], #'+modal_id+' input[type="number"]').val("");

    }

  return {
    selectDoctor: selectDoctor,
    addMedications: addMedications
  }

}();

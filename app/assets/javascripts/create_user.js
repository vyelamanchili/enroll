/* 
 * This js file was created for ui updates of the Create User Page
 */


 jQuery(document).ready(function($){

        /*If Ruby throws error disaply that error.*/
        if($('.error-block .alert-error').length){
            $('.error-block').show();
        }
        
        /* show password */
        $('.tlp-cls').click(function(){
            if($(this).prev('input').hasClass('type-pass')) {
                $(this).prev('input').attr('type','text');
                $(this).prev('input').removeClass('type-pass');
            } else {
                $(this).prev('input').attr('type','password');
                $(this).prev('input').addClass('type-pass');
            }
        });

        /* tooltip username and check username or email on blur */
        $('#user_email').keyup(function() {
        }).focus(function() {
            $(this).parent().next().show();
            if($(window).width() <= 480) {
                // $('.tooltip_box.user_tooltip').css('margin-top','45px');
                $('.tooltip_box').css('top','0px');
            }
            if($(window).width() <= 400) {
                $('.tooltip_box.user_tooltip').css('margin-top','45px');
                $('.tooltip_box').css('top','-60px');
            }
        }).blur(function() {
            $(this).parent().next().hide();
            var email = $(this).val();
            var testEmail = /^[A-Z0-9._%+-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i;
            if(email != '') {
                $(this).parent().removeClass('has-error');
                if (testEmail.test(email)){
                    $('.email-block').slideUp('slow');
                }
                else
                {
                    $('.email-block').slideDown('slow');
                }
            }
        });
        
        /* Added this as a workaround for not being able to add onSubmit js 
         * call for the new user create form.*/
        $('#new_user').submit(function(){
            return checkForm(this);
        });

        /* check password validation */
        $('#user_password').keyup(function() {
            onkeycheckForm();
        }).focus(function() {
            onkeycheckForm();
            $('#pswd_info').show();
            if($(window).width() <= 480) {
                $('.password1').css('margin-top','50px');
                $('.tooltip_box').css('top','-60px');
            }
            if($(window).width() <= 400) {
                $('.password1').css('margin-top','120px');
                $('.tooltip_box').css('top','-60px');
            }

        }).blur(function() {
            $('#pswd_info').hide();
            if($(window).width() <= 480) {
                $('.password1').css('margin-top','0px');
            }
        });

        /* check confirm password validation */
        $('#user_password_confirmation').keyup(function() {

            pas = $("#user_password");
            con_pas = $('#user_password_confirmation');
            pass1 = pas.val();
            pass2 = con_pas.val();
            var status;

            $('.con-pass').removeClass('conpass-success').text('');
            $('.con-pass').removeClass('conpass-false').text('');
            if(pass1 != '' && pass2.length > 0) {
                $('#user_password_confirmation').parent('.form-group').removeClass('has-error');
                if((pass1 != "" && pass1 != pass2)) {
                    $('.con-pass').addClass('conpass-false').text('Match');
                    con_pas.focus();
                    return false;
                }
                else {
                    $('.con-pass').addClass('conpass-success').text('Match');
                }
            }

        });

    });

    function onkeycheckForm(form) {

        username = $('#user_email');
        pas = $("#user_password");
        con_pas = $('#user_password_confirmation');
        user_val = username.val();
        pass1 = pas.val();
        pass2 = con_pas.val();
        var status;

        $('#longer').removeClass('valid').addClass('invalid');
        $('#length').removeClass('valid').addClass('invalid');
        $('#number').removeClass('valid').addClass('invalid');
        $('#lower').removeClass('valid').addClass('invalid');
        $('#upper').removeClass('valid').addClass('invalid');
        $('#spec_char').removeClass('valid').addClass('invalid');
        $('#wh_space').removeClass('valid').addClass('invalid');
        $('#mtt').removeClass('valid').addClass('invalid');
        $('#nm_uid').removeClass('valid').addClass('invalid');

        if(pass1.length > 0) {

            $('.alert').text();
            $('#user_password').parent('.form-group').removeClass('has-error');

            //validate the longer length
            if(pass1.length > 20) {
                $('#longer').removeClass('valid').addClass('invalid');
            }
            else {
                $('#longer').removeClass('invalid').addClass('valid');
            }

          //validate the length
            if(pass1.length < 8) {
                $('#length').removeClass('valid').addClass('invalid');
            }
            else {
                $('#length').removeClass('invalid').addClass('valid');
            }

            if(!(pass1.match(/[0-9]/))){
                $('#number').removeClass('valid').addClass('invalid');
            }
            else {
                $('#number').removeClass('invalid').addClass('valid');
            }

            //validate lowercase letter
            if ( pass1.match(/[a-z]/) ) {
                $('#lower').removeClass('invalid').addClass('valid');
            } else {
                $('#lower').removeClass('valid').addClass('invalid');
            }

            //validate uppercase letter
            if(!pass1.match(/[A-Z]/)) {
                $('#upper').removeClass('valid').addClass('invalid');
                status = false;
            }
            else {
                $('#upper').removeClass('invalid').addClass('valid');
            }

            //validate special character
            if(!(pass1.match(/.[!,@,#,$,%,^,&,*,?,_,~,-,(,)]/))) {
                $('#spec_char').removeClass('valid').addClass('invalid');
            }
            else {
                $('#spec_char').removeClass('invalid').addClass('valid');
            }

            //validate white space
            if ( !(pass1.match(/\s/)) ) {
                $('#wh_space').removeClass('invalid').addClass('valid');
            } else {
                $('#wh_space').removeClass('valid').addClass('invalid');
            }

            //validate not match user id
            if (user_val.length > 0 && pass1.toLowerCase().indexOf(user_val.toLowerCase()) >= 0) {
                $('#nm_uid').removeClass('valid').addClass('invalid');
            } else {
                $('#nm_uid').removeClass('invalid').addClass('valid');
            }

            //validate repeated no more than twice
            var max_repeats = 2;
            pass_str = pass1.toLowerCase();
            var chars = pass_str.split('');
            var cmap = {};
            for (var i = 0; i < chars.length; i++) {
                if (! cmap.hasOwnProperty(chars[i])) cmap[chars[i]] = 0;
                cmap[chars[i]]++;
            }
            for (var p in cmap) {
                if (cmap[p] > max_repeats){
                    $('#mtt').removeClass('valid').addClass('invalid');
                    return false;
                }
                else {
                    $('#mtt').removeClass('invalid').addClass('valid');
                }
            }

        }
    }

    function checkForm(form) {

        username = $('#user_email');
        pas = $("#user_password");
        con_pas = $('#user_password_confirmation');
        user_val = username.val();
        pass1 = pas.val();
        pass2 = con_pas.val();
        var status = true;
        var pass1_status = true;

        $('.error-block').hide();
        $('.alert').text();
        $('.form-group').removeClass('has-error');
        $('#user_password').parent('.form-group').removeClass('has-error');
        $('#conf_pass').parent('.form-group').removeClass('has-error');

        if(user_val == '') {
            username.parent('.form-group').addClass('has-error');
            $('.error-block').show();
            $('.alert').removeClass('alert-success').addClass('alert-danger').text('You must complete the highlighted field(s).');
            status = false;
        }

        if(pass1 == ""){
            $('#user_password').parent('.form-group').addClass('has-error');
            $('.error-block').show();
            $('.alert').removeClass('alert-success').addClass('alert-danger').text("You must complete the highlighted field(s).");
            status = false;
        }
        else {

            $('#longer').removeClass('valid').addClass('invalid');
            $('#length').removeClass('valid').addClass('invalid');
            $('#number').removeClass('valid').addClass('invalid');
            $('#lower').removeClass('valid').addClass('invalid');
            $('#upper').removeClass('valid').addClass('invalid');
            $('#spec_char').removeClass('valid').addClass('invalid');
            $('#wh_space').removeClass('valid').addClass('invalid');
            $('#mtt').removeClass('valid').addClass('invalid');
            $('#nm_uid').removeClass('valid').addClass('invalid');

            if(pass1.length > 0) {

                //validate the longer length
                if(pass1.length > 20) {
                    $('#longer').removeClass('valid').addClass('invalid');
                    pass1_status = false;
                }
                else {
                    $('#longer').removeClass('invalid').addClass('valid');
                }

              //validate the length
                if(pass1.length < 8) {
                    $('#length').removeClass('valid').addClass('invalid');
                    pass1_status = false;
                }
                else {
                    $('#length').removeClass('invalid').addClass('valid');
                }

                if(!(pass1.match(/[0-9]/))){
                    $('#number').removeClass('valid').addClass('invalid');
                    pass1_status = false;
                }
                else {
                    $('#number').removeClass('invalid').addClass('valid');
                }

                //validate lowercase letter
                if ( pass1.match(/[a-z]/) ) {
                    $('#lower').removeClass('invalid').addClass('valid');
                } else {
                    $('#lower').removeClass('valid').addClass('invalid');
                    pass1_status = false;
                }

                //validate uppercase letter
                if(!pass1.match(/[A-Z]/)) {
                    $('#upper').removeClass('valid').addClass('invalid');
                    pass1_status = false;
                }
                else {
                    $('#upper').removeClass('invalid').addClass('valid');
                }

                //validate special character
                if(!(pass1.match(/.[!,@,#,$,%,^,&,*,?,_,~,-,(,)]/))) {
                    $('#spec_char').removeClass('valid').addClass('invalid');
                    pass1_status = false;
                }
                else {
                    $('#spec_char').removeClass('invalid').addClass('valid');
                }

                //validate white space
                if ( !(pass1.match(/\s/)) ) {
                    $('#wh_space').removeClass('invalid').addClass('valid');
                } else {
                    $('#wh_space').removeClass('valid').addClass('invalid');
                    pass1_status = false;
                }

                //validate not match user id
                if (user_val.length > 0 && pass1.toLowerCase().indexOf(user_val.toLowerCase()) >= 0) {
                    $('#nm_uid').removeClass('valid').addClass('invalid');
                    pass1_status = false;
                } else {
                    $('#nm_uid').removeClass('invalid').addClass('valid');
                }

                //validate repeated no more than twice
                var max_repeats = 2;
                pass_str = pass1.toLowerCase();
                var chars = pass_str.split('');
                var cmap = {};
                for (var i = 0; i < chars.length; i++) {
                    if (! cmap.hasOwnProperty(chars[i])) cmap[chars[i]] = 0;
                    cmap[chars[i]]++;
                }
                for (var p in cmap) {
                    if (cmap[p] > max_repeats){
                        $('#mtt').removeClass('valid').addClass('invalid');
                        pass1_status = false;
                    }
                    else {
                        $('#mtt').removeClass('invalid').addClass('valid');
                    }
                }

                if (pass1_status == false) {
                    $('.error-block').show();
                    $('.alert').removeClass('alert-success').addClass('alert-danger').text("Password didn't match with requirements.");
                    pas.focus();
                    $('#user_password').parent('.form-group').addClass('has-error');
                    return false;
                }
            }
        }


        if(pass2 == ""){
            $('#user_password_confirmation').parent('.form-group').addClass('has-error');
            $('.error-block').show();
            $('.alert').removeClass('alert-success').addClass('alert-danger').text("You must complete the highlighted field(s).");
            status = false;
        }

        if (status == false) {
            return false;
        }

        if((user_val != "" && pass1 != "" && pass2 != "" )) {

            if( pass1 == pass2 ) {
                $('#user_password_confirmation').parent('.form-group').removeClass('has-error');
                return true;
            }
            else {
                $('#user_password_confirmation').parent('.form-group').addClass('has-error');
                $('.error-block').show();
                $('.alert').removeClass('alert-success').addClass('alert-danger').text("Confirm password didn't match. Please try again.");
                return false;
            }
        }
    }

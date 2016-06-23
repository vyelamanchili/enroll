var PhoneEntry = React.createClass({
  getDefaultProps: function() {
    return({kinds: []});
  },
  styleize: function() {
    $(this.numberInput).floatlabel({
      slideInput: false
    });
    $(this.numberInput).mask("999-9999");
    $(this.areaCodeInput).floatlabel({
      slideInput: false
    });
    $(this.areaCodeInput).mask("999");
    $(this.extensionInput).floatlabel({
      slideInput: false
    });
    $(this.kindDropdown).selectric();
  },
  componentDidMount: function() {
    this.styleize();
  },
  componentDidUpdate: function() {
    this.styleize();
  },
  checkPhone : function() {
    var phoneRegex = /^\d{3}-\d{4}$/;
    var textbox = this.numberInput;
    if (textbox.value == '') {
      textbox.setCustomValidity('Please fill out this phone number field.');
    } else if(!phoneRegex.test(textbox.value)){
      textbox.setCustomValidity('please enter a valid phone number.');
    } else {
      textbox.setCustomValidity('');
    }
  },
  checkAreaCode : function() {
    var phoneRegex = /^\d{3}$/;
    var textbox = this.areaCodeInput;
    if (textbox.value == '') {
      textbox.setCustomValidity('Please fill out this area code field.');
    } else if(!phoneRegex.test(textbox.value)){
      textbox.setCustomValidity('please enter a valid area code.');
    } else {
      textbox.setCustomValidity('');
    }
  },
  render: function() {
     return(
       <div className="row no-buffer row-form-wrapper">
         <div className="col-md-3 col-sm-3 col-xs-12 form-group form-group-lg no-pd">
	   <select name={this.props.prefix + "[kind]"} className="form-control interaction-choice-control-office-location-phone-kind" placeHolder="KIND" defaultValue={this.props.kind}
	     ref={function(input) { this.kindDropdown = input }.bind(this)}> 
	     {this.props.kinds.map(function(kind_info) {
                return(
                  <option value={kind_info[1]} key={kind_info[1]}>{kind_info[0]}</option>
		);
	     })}
	   </select>
	 </div>
         <div className="col-md-3 col-sm-3 col-xs-12 form-group form-group-lg no-pd">
	   <input type="text" name={this.props.prefix + "[area_code]"} defaultValue={this.props.area_code} placeholder="AREA CODE" className="form-control area_code interaction-field-control-office-location-phone-area-code" required="true" ref={function(input) { this.areaCodeInput = input }.bind(this)} onInput={this.checkAreaCode}/>
	 </div>
         <div className="col-md-3 col-sm-3 col-xs-12 form-group form-group-lg no-pd">
	   <input type="text" name={this.props.prefix + "[number]"} defaultValue={this.props.number} placeholder="NUMBER" className="form-control phone_number7 interaction-field-control-office-location-phone-number" required="true" ref={function(input) { this.numberInput = input }.bind(this)} onInput={this.checkPhone} />
	 </div>
         <div className="col-md-3 col-sm-3 col-xs-12 form-group form-group-lg no-pd border_bottom_zero">
           <input type="text" name={this.props.prefix + "[extension]"} defaultValue={this.props.extension}  className="form-control interaction-field-control-office-location-phone-extension" placeholder="EXTENSION"
	     ref={function(input) { this.extensionInput = input }.bind(this)} />
	 </div>
       </div>
	   );
  }
});

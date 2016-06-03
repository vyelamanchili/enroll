const ConfirmTerminateCensusEmployeeModal = React.createClass({
  statics: {
    confirmTerminateCensusEmployee: function($thisObj, census_employee_id) {
      if ( $thisObj.closest('tr').find('input').val().length > 0 ) {

        $('#Confirm_terminate_census_employee_modal-'+census_employee_id).modal("show");
      } else {
        alert('Please provide a termination date');
        Modal = ReactBootstrap.Modal;

      }
    }
  },

  render: function() {
    return (
      <div id={"Confirm_terminate_census_employee_modal-" + this.props.census_employee._id} className="confirm_terminate_census_employee_modal modal fade static-modal" role="dialog" >
        <Modal.Dialog>
          <Modal.Header>
            <button type="button" className="close" data-dismiss="modal">&times;</button>
            <h4 className="modal-title"><i className="fa fa-trash-o fa-lg" aria-hidden="true"></i> &nbsp;Terminate Employee</h4>
          </Modal.Header>

          <Modal.Body>
            <p>Are you sure you want to terminate { this.props.full_name }?
            <br/>
            <strong>Note: </strong>
            <span className="text-danger">
            { this.props.full_name }'s coverage will end on { this.props.coverage_ends }
            </span>
            </p>
          </Modal.Body>

          <Modal.Footer>
            <span className="btn btn-default" data-dismiss="modal">Cancel</span>
            <span className="btn btn-primary delete_confirm"><i className="fa fa-trash-o" aria-hidden="true"></i> Terminate</span>
          </Modal.Footer>

        </Modal.Dialog>
      </div>
    )
  }

});

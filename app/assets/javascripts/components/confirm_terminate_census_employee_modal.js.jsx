var Confirm_terminate_census_employee_modal = React.createClass({


  render: function() {
    return (
      <div id={"Confirm_terminate_census_employee_modal-" + this.props.census_employee._id} className="confirm_terminate_census_employee_modal modal fade" role="dialog">
        <div className="modal-dialog">
          <div className="modal-content">
            <div className="modal-header">
              <button type="button" className="close" data-dismiss="modal">&times;</button>
              <h4 className="modal-title"><i className="fa fa-trash-o fa-lg" aria-hidden="true"></i> Terminate Employee</h4>
            </div>
            <div className="modal-body">
              <p>Are you sure you want to terminate { this.props.full_name }?
              <br/>
              <strong>Note: </strong>
              <span className="text-danger">
              { this.props.full_name }'s coverage will end on { this.props.coverage_ends }
              </span>
              </p>
            </div>
            <div className="modal-footer">
              <span className="btn btn-trans" data-dismiss="modal">Cancel</span>
              <span className="btn btn-primary btn-br mtz delete_confirm"><i className="fa fa-trash-o" aria-hidden="true"></i> Terminate</span>
            </div>
          </div>
        </div>
      </div>
    )
  }
});

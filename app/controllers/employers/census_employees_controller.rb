class Employers::CensusEmployeesController < ApplicationController
  before_action :find_employer
  before_action :find_census_employee, only: [:edit, :update, :show, :delink, :terminate, :rehire, :benefit_group, :assignment_benefit_group ]
  before_action :updateable?, except: [:edit, :show, :benefit_group, :assignment_benefit_group]
  layout "two_column"
  def new
    @census_employee = build_census_employee
    if params[:modal].present?
      respond_to do |format|
        format.js { render "employers/employer_profiles/upload_employees" }
      end

    end
  end

  def create
    @census_employee = CensusEmployee.new
    @census_employee.build_from_params(census_employee_params, benefit_group_id)

    if renewal_benefit_group_id.present?
      benefit_group = BenefitGroup.find(BSON::ObjectId.from_string(renewal_benefit_group_id))
      if @census_employee.renewal_benefit_group_assignment.try(:benefit_group_id) != benefit_group.id
        @census_employee.add_renew_benefit_group_assignment(benefit_group)
      end
    end

    @census_employee.employer_profile = @employer_profile
    if @census_employee.save
      if benefit_group_id.present?
        @census_employee.send_invite!
        @census_employee.construct_employee_role_for_match_person
        flash[:notice] = "Census Employee is successfully created."
      else
        flash[:notice] = "Your employee was successfully added to your roster."
        #flash[:notice] += "Note: an employee must be assigned to a benefit group before they can enroll for benefits"
      end
      redirect_to employers_employer_profile_path(@employer_profile, tab: 'employees')
    else
      begin
        missing_kind = census_employee_params['email_attributes']['kind']==''
        @census_employee.errors['Email']='Kind must be selected' if missing_kind
      rescue
      end
      @reload = true
      render action: "new"
    end
    #else
      #@census_employee.benefit_group_assignments.build if @census_employee.benefit_group_assignments.blank?
      #flash[:error] = "Please select Benefit Group."
      #render action: "new"
    #end
  end

  def edit
    @census_employee.build_address unless @census_employee.address.present?
    @census_employee.build_email unless @census_employee.email.present?
    @census_employee.benefit_group_assignments.build unless @census_employee.benefit_group_assignments.present?
  end

  def update
    if benefit_group_id.present?
      benefit_group = BenefitGroup.find(BSON::ObjectId.from_string(benefit_group_id))

      if @census_employee.active_benefit_group_assignment.try(:benefit_group_id) != benefit_group.id
        @census_employee.find_or_create_benefit_group_assignment(benefit_group)
      end
    end

    if renewal_benefit_group_id.present?
      benefit_group = BenefitGroup.find(BSON::ObjectId.from_string(renewal_benefit_group_id))
      if @census_employee.renewal_benefit_group_assignment.try(:benefit_group_id) != benefit_group.id
        @census_employee.add_renew_benefit_group_assignment(benefit_group)
      end
    end

    @census_employee.attributes = census_employee_params
    destroyed_dependent_ids = census_employee_params[:census_dependents_attributes].delete_if{|k,v| v.has_key?("_destroy") }.values.map{|x| x[:id]} if census_employee_params[:census_dependents_attributes]

    authorize @census_employee, :update?

    if @census_employee.save
      if destroyed_dependent_ids.present?
        destroyed_dependent_ids.each do |g|
          census_dependent = @census_employee.census_dependents.find(g)
          census_dependent.delete
        end
      end
      flash[:notice] = "Census Employee is successfully updated."
      if benefit_group_id.present?
        flash[:notice] = "Census Employee is successfully updated."
      else
        flash[:notice] = "Note: new employee cannot enroll on #{Settings.site.short_name} until they are assigned a benefit group. "
        flash[:notice] += "Census Employee is successfully updated."
      end
      redirect_to employers_employer_profile_path(@employer_profile, tab: 'employees')
    else
      @reload = true
      render action: "edit"
    end
    #else
      #flash[:error] = "Please select Benefit Group."
      #render action: "edit"
    #end
  end

  def terminate
    termination_date = params["termination_date"]
    if termination_date.present?
      termination_date = DateTime.strptime(termination_date, '%m/%d/%Y').try(:to_date)
    else
      termination_date = ""
    end
    last_day_of_work = termination_date
    if termination_date.present?
      @census_employee.terminate_employment(last_day_of_work)
      if termination_date >= (Date.today-60.days)
        @fa = @census_employee.save
      else
      end

    end
    respond_to do |format|
      format.js {
        if termination_date.present? && @fa
          flash[:notice] = "Successfully terminated Census Employee."
          render text: true
        else
          flash[:error] = "Census Employee could not be terminated: Termination date must be within the past 60 days."
          render text: false
        end
      }
      format.all {
        flash[:notice] = "Successfully terminated Census Employee."
        redirect_to employers_employer_profile_path(@employer_profile)
      }
    end
  end

  def rehire
    rehiring_date = params["rehiring_date"]
    if rehiring_date.present?
      rehiring_date = DateTime.strptime(rehiring_date, '%m/%d/%Y').try(:to_date)
    else
      rehiring_date = ""
    end
    @rehiring_date = rehiring_date
    if @rehiring_date.present? && @rehiring_date > @census_employee.employment_terminated_on
      new_census_employee = @census_employee.replicate_for_rehire
      if new_census_employee.present? # not an active family, then it is ready for rehire.#
        new_census_employee.hired_on = @rehiring_date
        if new_census_employee.valid? && @census_employee.valid?
          @census_employee.save
          new_census_employee.save

          # for new_census_employee
          new_census_employee.build_address if new_census_employee.address.blank?
          new_census_employee.add_default_benefit_group_assignment          
          new_census_employee.construct_employee_role_for_match_person
          
          @census_employee = new_census_employee
          flash[:notice] = "Successfully rehired Census Employee."
        else
          flash[:error] = "Error during rehire."
        end
      else # active family, dont replicate for rehire, just return error
        flash[:error] = "Census Employee is already active."
      end
    elsif @rehiring_date.blank?
      flash[:error] = "Please enter rehiring date."
    else
      flash[:error] = "Rehiring date can't occur before terminated date."
    end
  end

  def show
    if @benefit_group_assignment = @census_employee.active_benefit_group_assignment
      @hbx_enrollments = @benefit_group_assignment.hbx_enrollments
      @benefit_group = @benefit_group_assignment.benefit_group
    end

    # PlanCostDecorator.new(@hbx_enrollment.plan, @hbx_enrollment, @benefit_group, reference_plan) if @hbx_enrollment.present? and @benefit_group.present? and reference_plan.present?
  end

  def delink
    employee_role = @census_employee.employee_role
    if employee_role.present?
      employee_role.census_employee_id = nil
      user = employee_role.person.user
      user.roles.delete("employee")
    end
    benefit_group_assignment = @census_employee.benefit_group_assignments.last
    hbx_enrollment = benefit_group_assignment.hbx_enrollment
    benefit_group_assignment.delink_coverage
    @census_employee.delink_employee_role

    if @census_employee.valid?
      user.try(:save)
      employee_role.try(:save)
      benefit_group_assignment.save
      hbx_enrollment.destroy
      @census_employee.save

      flash[:notice] = "Successfully delinked census employee."
      redirect_to employers_employer_profile_path(@employer_profile)
    else
      flash[:alert] = "Delink census employee failure."
      redirect_to employers_employer_profile_path(@employer_profile)
    end
  end

  def benefit_group
    @census_employee.benefit_group_assignments.build unless @census_employee.benefit_group_assignments.present?
  end

  def assignment_benefit_group
    benefit_group = @employer_profile.plan_years.first.benefit_groups.find_by(id: benefit_group_id)
    new_benefit_group_assignment = BenefitGroupAssignment.new_from_group_and_census_employee(benefit_group, @census_employee)

    if @census_employee.active_benefit_group_assignment.try(:benefit_group_id) != new_benefit_group_assignment.benefit_group_id
      @census_employee.add_benefit_group_assignment(new_benefit_group_assignment)
    end

    if @census_employee.save
      flash[:notice] = "Assignment benefit group is successfully."
      redirect_to employers_employer_profile_path(@employer_profile)
    else
      render action: "benefit_group"
    end
  end

  private

  def updateable?
    authorize ::EmployerProfile, :updateable?
  end  

  def benefit_group_id
    params[:census_employee][:benefit_group_assignments_attributes]["0"][:benefit_group_id] rescue nil
  end

  def renewal_benefit_group_id
    params[:census_employee][:renewal_benefit_group_assignments][:benefit_group_id] rescue nil
  end

  def census_employee_params
=begin
    [:dob, :hired_on].each do |attr|
      if params[:census_employee][attr].present?
        params[:census_employee][attr] = DateTime.strptime(params[:census_employee][attr].to_s, '%m/%d/%Y').try(:to_date)
      end
    end

    census_dependents_attributes = params[:census_employee][:census_dependents_attributes]
    if census_dependents_attributes.present?
      census_dependents_attributes.each do |id, dependent_params|
        if census_dependents_attributes[id][:dob].present?
          params[:census_employee][:census_dependents_attributes][id][:dob] = DateTime.strptime(dependent_params[:dob].to_s, '%m/%d/%Y').try(:to_date)
        end
      end
    end
=end

    params.require(:census_employee).permit(:id, :employer_profile_id,
        :id, :first_name, :middle_name, :last_name, :name_sfx, :dob, :ssn, :gender, :hired_on, :employment_terminated_on, :is_business_owner,
        :address_attributes => [ :id, :kind, :address_1, :address_2, :city, :state, :zip ],
        :email_attributes => [:id, :kind, :address],
      :census_dependents_attributes => [
          :id, :first_name, :last_name, :middle_name, :name_sfx, :dob, :gender, :employee_relationship, :_destroy, :ssn
        ]
      )
  end

  def find_employer
    @employer_profile = EmployerProfile.find(params["employer_profile_id"])
  end

  def find_census_employee
    id = params[:id] || params[:census_employee_id]
    @census_employee = CensusEmployee.find(id)
  end

  def build_census_employee
    @census_employee = CensusEmployee.new
    @census_employee.build_address
    @census_employee.build_email
    @census_employee.benefit_group_assignments.build
    @census_employee
  end

end

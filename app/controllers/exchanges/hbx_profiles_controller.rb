class Exchanges::HbxProfilesController < ApplicationController
  include DataTablesAdapter

  before_action :check_hbx_staff_role, except: [:request_help, :show, :assister_index, :family_index]
  before_action :set_hbx_profile, only: [:edit, :update, :destroy]
  before_action :find_hbx_profile, only: [:employer_index, :broker_agency_index, :inbox, :configuration, :show, :binder_index]
  #before_action :authorize_for, except: [:edit, :update, :destroy, :request_help, :staff_index, :assister_index]
  #before_action :authorize_for_instance, only: [:edit, :update, :destroy]
  before_action :check_csr_or_hbx_staff, only: [:family_index]
  # GET /exchanges/hbx_profiles
  # GET /exchanges/hbx_profiles.json
  layout 'single_column'
  
  def index
    @organizations = Organization.exists(hbx_profile: true)
    @hbx_profiles = @organizations.map {|o| o.hbx_profile}
  end

  def binder_paid
    EmployerProfile.update_status_to_binder_paid(params[:employer_profile_ids])
    flash["notice"] = "Successfully submitted the selected employer(s) for binder paid."
    redirect_to exchanges_hbx_profiles_root_path
  end

  def transmit_group_xml
    HbxProfile.transmit_group_xml(params[:id].split)
    flash["notice"] = "Successfully transmitted the employer group xml."
    redirect_to exchanges_hbx_profiles_root_path
  end

  def employer_index
    @q = params.permit(:q)[:q]
    @orgs = Organization.search(@q).exists(employer_profile: true)
    @page_alphabets = page_alphabets(@orgs, "legal_name")
    page_no = cur_page_no(@page_alphabets.first)
    @organizations = @orgs.where("legal_name" => /^#{page_no}/i)

    @employer_profiles = @organizations.map {|o| o.employer_profile}

    respond_to do |format|
      format.html { render "employers/employer_profiles/index" }
      format.js {}
    end
  end

  def generate_invoice
    @organizations= Organization.where(:id.in => params[:employerId]).all
    @organizations.each do |org|
      @employer_invoice = EmployerInvoice.new(org)
      @employer_invoice.save_and_notify_with_clean_up
    end

    respond_to do |format|
      format.js
    end
  end

  def employer_invoice

    # Dynamic Filter values for upcoming 30, 60, 90 days renewals
    @next_30_day = TimeKeeper.date_of_record.next_month.beginning_of_month
    @next_60_day = @next_30_day.next_month
    @next_90_day = @next_60_day.next_month


    respond_to do |format|
      format.html
      format.js
    end
  end


  # This method provides the jquery datatable payload for the ajax call
  def employer_invoice_datatable

    dt_query = extract_datatable_parameters
    employers = []

    # datatable records with no filter should default to scope "invoice_view_all"
    all_employers = Organization.where(:employer_profile => {:$exists => 1}).invoice_view_all
    employers = all_employers
    is_search = false

    if !params[:invoice_date_criteria].blank? && params[:invoice_date_criteria] != "All"
      invoice_date = params[:invoice_date_criteria].split(":")[0]
      invoice_state = params[:invoice_date_criteria].split(":")[1]

      employers = Organization.where(:employer_profile => {:$exists => 1}).all_employers_by_plan_year_start_on(Date.strptime(invoice_date,"%m/%d/%Y"))
      if invoice_state == "R"
        employers = employers.invoice_view_renewing
      elsif invoice_state == "I"
        employers = employers.invoice_view_initial
      end
      is_search = true
    end


    if dt_query.search_string.blank? && (params[:invoice_date_criteria].blank? || params[:invoice_date_criteria] == "All")
      employers = all_employers
    else
      #this will search on FEIN or Legal Name of an employer
      employer_ids = Organization.where(:employer_profile => {:$exists => 1}).search(dt_query.search_string).pluck(:id)
      employers = employers.where({:id => {"$in" => employer_ids}})
      is_search = true

    end

    #order records by plan_year.start_on and by legal_name
    employers = employers.er_invoice_data_table_order


    #records_filtered is for datatable required so it nows how many records were filtered.
    @records_filtered = is_search ? employers.count : all_employers.count

    #slice resultset so it returns the records in the desiged page number
    array_from = dt_query.skip.to_i #starting index
    array_to = dt_query.skip.to_i + [dt_query.take.to_i,employers.count.to_i].min - 1 #to index
    employers = employers[array_from..array_to]

    datatable_payload = employers.map { |employer_invoice|
      {
        :invoice_id => ('<input type="checkbox" name="employerId[]" value="' + employer_invoice.id.to_s + '">'),
        :fein => employer_invoice.fein,
        :legal_name => (view_context.link_to employer_invoice.legal_name, employers_employer_profile_path(employer_invoice.employer_profile)+"?tab=home"),
        :state => employer_invoice.employer_profile.aasm_state.humanize,
        :plan_year => employer_invoice.employer_profile.latest_plan_year.try(:effective_date).to_s,
        :is_conversion => (employer_invoice.employer_profile.is_conversion? ? '<i class="fa fa-check-square-o" aria-hidden="true"></i>' : nil.to_s),
        :enrolled => employer_invoice.employer_profile.try(:latest_plan_year).try(:enrolled).try(:count).to_i.to_s + "/" + employer_invoice.employer_profile.try(:latest_plan_year).try(:waived_count).to_i.to_s,
        :remaining => employer_invoice.employer_profile.try(:latest_plan_year).try(:eligible_to_enroll_count).to_i - employer_invoice.employer_profile.try(:latest_plan_year).try(:enrolled).try(:count).to_i,
        :eligible => employer_invoice.employer_profile.try(:latest_plan_year).try(:eligible_to_enroll_count).to_i,
        :enrollment_ratio => (employer_invoice.employer_profile.try(:latest_plan_year).try(:enrollment_ratio).to_f * 100).to_i,
        :is_current_month_invoice_generated => employer_invoice.current_month_invoice.present? ? '<i class="fa fa-check-square" style="color:green" aria-hidden="true"></i>' : nil.to_s
      }
    }

    @draw = dt_query.draw
    @total_records = all_employers.count

    @payload = datatable_payload
    render
  end

  def staff_index
    @q = params.permit(:q)[:q]
    @staff = Person.where(:$or => [{csr_role: {:$exists => true}}, {assister_role: {:$exists => true}}])
    @page_alphabets = page_alphabets(@staff, "last_name")
    page_no = cur_page_no(@page_alphabets.first)
    if @q.nil?
      @staff = @staff.where(last_name: /^#{page_no}/i)
    else
      @staff = @staff.where(last_name: @q)
    end
  end

  def assister_index
    @q = params.permit(:q)[:q]
    @staff = Person.where(assister_role: {:$exists =>true})
    @page_alphabets = page_alphabets(@staff, "last_name")
    page_no = cur_page_no(@page_alphabets.first)
    if @q.nil?
      @staff = @staff.where(last_name: /^#{page_no}/i)
    else
      @staff = @staff.where(last_name: @q)
    end
  end

  def find_email(agent, role)
    if role == 'Broker'
      agent.try(:broker_role).try(:email).try(:address)
    else
      agent.try(:user).try(:email)
    end
  end

  def request_help
    role = nil
    if params[:type]
      cac_flag = params[:type] == 'CAC'
      match = CsrRole.find_by_name(params[:firstname], params[:lastname], cac_flag)
      if match.count > 0
        agent = match.first
        role = cac_flag ? 'Certified Applicant Counselor' : 'Customer Service Representative'
      end
    else
      if params[:broker].present?
        agent = Person.find(params[:broker])
        broker_role_id = agent.broker_role.id
        consumer = Person.find(params[:person])
        family = consumer.primary_family
        family.hire_broker_agency(broker_role_id)
        role = 'Broker'
      else
        agent = Person.find(params[:assister])
        role = 'In-Person Assister'
      end
    end
    if role
      status_text = 'Message sent to ' + role + ' ' + agent.full_name + ' <br>'
      if find_email(agent, role)
        agent_assistance_messages(params,agent,role)
      else

        status_text = "Agent has no email.   Please select another"
      end
    else
      status_text = call_customer_service params[:firstname].strip, params[:lastname].strip
    end
    @person = Person.find(params[:person])
    broker_view = render_to_string 'insured/families/_consumer_brokers_widget', :layout => false
    render :text => {broker: broker_view, status: status_text}.to_json, layout: false
  end

  def family_index
    @q = params.permit(:q)[:q]
    page_string = params.permit(:families_page)[:families_page]
    page_no = page_string.blank? ? nil : page_string.to_i
    unless @q.present?
      @families = Family.page page_no
      @total = Family.count
    else
      total_families = Person.search(@q).map(&:families).flatten.uniq
      @total = total_families.count
      @families = Kaminari.paginate_array(total_families).page page_no
    end
    respond_to do |format|
      format.html { render "insured/families/index" }
      format.js {}
    end
  end

  def broker_agency_index
    @broker_agency_profiles = BrokerAgencyProfile.all

    respond_to do |format|
      format.html { render "broker" }
      format.js {}
    end
  end

  def general_agency_index
    page_string = params.permit(:gas_page)[:gas_page]
    page_no = page_string.blank? ? nil : page_string.to_i

    status_params = params.permit(:status)
    @status = status_params[:status] || 'is_applicant'
    @general_agency_profiles = GeneralAgencyProfile.filter_by(@status)
    @general_agency_profiles = Kaminari.paginate_array(@general_agency_profiles).page(page_no)

    respond_to do |format|
      format.html { render 'general_agency' }
      format.js
    end
  end

  def issuer_index
    @issuers = CarrierProfile.all

    respond_to do |format|
      format.html { render "issuer_index" }
      format.js {}
    end
  end

  def verification_index
    @families = Family.by_enrollment_individual_market.where(:'households.hbx_enrollments.aasm_state' => "enrolled_contingent").page(params[:page]).per(15)
    respond_to do |format|
      format.html { render partial: "index_verification" }
      format.js {}
    end
  end

  def binder_index
    @organizations = Organization.retrieve_employers_eligible_for_binder_paid

    respond_to do |format|
      format.html { render "employers/employer_profiles/binder_index" }
      format.js {}
    end
  end

  def binder_index_datatable
    dt_query = extract_datatable_parameters
    organizations = []

    all_organizations = Organization.retrieve_employers_eligible_for_binder_paid

    organizations = if dt_query.search_string.blank?
      all_organizations
    else
      org_ids = Organization.search(dt_query.search_string).pluck(:id)
      all_organizations.where({
        "id" => {"$in" => org_ids}
      })
    end

    @draw = dt_query.draw
    @total_records = all_organizations.count
    @records_filtered = organizations.count
    @organizations = organizations.skip(dt_query.skip).limit(dt_query.take)
    render

  end

  def verifications_index_datatable
    dt_query = extract_datatable_parameters
    families = []
    all_families = Family.by_enrollment_individual_market.where(:'households.hbx_enrollments.aasm_state' => "enrolled_contingent")
    if dt_query.search_string.blank?
      families = all_families
    else
      person_ids = Person.search(dt_query.search_string).pluck(:id)
      families = all_families.where({
        "family_members.person_id" => {"$in" => person_ids}
      })
    end
    @draw = dt_query.draw
    @total_records = all_families.count
    @records_filtered = families.count
    @families = families.skip(dt_query.skip).limit(dt_query.take)
    render
  end

  def product_index
    respond_to do |format|
      format.html { render "product_index" }
      format.js {}
    end
  end

  def configuration
    @time_keeper = Forms::TimeKeeper.new

    respond_to do |format|
      format.html { render partial: "configuration_index" }
      format.js {}
    end
  end

  # GET /exchanges/hbx_profiles/1
  # GET /exchanges/hbx_profiles/1.json
  def show
    if current_user.has_csr_role? || current_user.try(:has_assister_role?)
      redirect_to home_exchanges_agents_path
      return
    else
      unless current_user.has_hbx_staff_role?
        redirect_to root_path, :flash => { :error => "You must be an HBX staff member" }
        return
      end
    end
    session[:person_id] = nil
    session[:dismiss_announcements] = nil
    @unread_messages = @profile.inbox.unread_messages.try(:count) || 0
  end

  # GET /exchanges/hbx_profiles/new
  def new
    @organization = Organization.new
    @hbx_profile = @organization.build_hbx_profile
  end

  # GET /exchanges/hbx_profiles/1/edit
  def edit
  end

  # GET /exchanges/hbx_profiles/1/inbox
  def inbox
    @inbox_provider = current_user.person.hbx_staff_role.hbx_profile
    @folder = params[:folder] || 'inbox'
    @sent_box = true
  end

  # POST /exchanges/hbx_profiles
  # POST /exchanges/hbx_profiles.json
  def create
    @organization = Organization.new(organization_params)
    @hbx_profile = @organization.build_hbx_profile(hbx_profile_params.except(:organization))

    respond_to do |format|
      if @hbx_profile.save
        format.html { redirect_to exchanges_hbx_profile_path @hbx_profile, notice: 'HBX Profile was successfully created.' }
        format.json { render :show, status: :created, location: @hbx_profile }
      else
        format.html { render :new }
        format.json { render json: @hbx_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /exchanges/hbx_profiles/1
  # PATCH/PUT /exchanges/hbx_profiles/1.json
  def update
    respond_to do |format|
      if @hbx_profile.update(hbx_profile_params)
        format.html { redirect_to exchanges_hbx_profile_path @hbx_profile, notice: 'HBX Profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @hbx_profile }
      else
        format.html { render :edit }
        format.json { render json: @hbx_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exchanges/hbx_profiles/1
  # DELETE /exchanges/hbx_profiles/1.json
  def destroy
    @hbx_profile.destroy
    respond_to do |format|
      format.html { redirect_to exchanges_hbx_profiles_path, notice: 'HBX Profile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def set_date
    forms_time_keeper = Forms::TimeKeeper.new(params[:forms_time_keeper])
    begin
      forms_time_keeper.set_date_of_record(forms_time_keeper.forms_date_of_record)
      flash[:notice] = "Date of record set to " + TimeKeeper.date_of_record.strftime("%m/%d/%Y")
    rescue Exception=>e
      flash[:error] = "Failed to set date of record, " + e.message
    end
    redirect_to exchanges_hbx_profiles_root_path
  end

private

  def agent_assistance_messages(params, agent, role)
    if params[:person].present?
      insured = Person.find(params[:person])
      first_name = insured.first_name
      last_name = insured.last_name
      name = insured.full_name
      insured_email = insured.emails.last.try(:address) || insured.try(:user).try(:email)
      root = 'http://' + request.env["HTTP_HOST"]+'/exchanges/agents/resume_enrollment?person_id=' + params[:person] +'&original_application_type:'
      body =
        "Please contact #{insured.first_name} #{insured.last_name}. <br/> " +
        "Plan Shopping help request from Person Id #{insured.id}, email #{insured_email}.<br/>" +
        "Additional PII is SSN #{insured.ssn} and DOB #{insured.dob}.<br>" +
        "<a href='" + root+"phone'>Assist Customer</a>  <br>"
    else
      first_name = params[:first_name]
      last_name = params[:last_name]
      name = first_name.to_s + ' ' + last_name.to_s
      insured_email = params[:email]
      body =  "Please contact #{first_name} #{last_name}. <br/>" +
        "Plan shopping help has been requested by #{insured_email}<br>"
      body += "SSN #{params[:ssn]} <br>" if params[:ssn].present?
      body += "DOB #{params[:dob]} <br>" if params[:dob].present?
    end
    hbx_profile = HbxProfile.find_by_state_abbreviation('DC')
    message_params = {
      sender_id: hbx_profile.id,
      parent_message_id: hbx_profile.id,
      from: 'Plan Shopping Web Portal',
      to: "Agent Mailbox",
      subject: "Please contact #{first_name} #{last_name}. ",
      body: body,
      }
    create_secure_message message_params, hbx_profile, :sent
    create_secure_message message_params, agent, :inbox
    result = UserMailer.new_client_notification(find_email(agent,role), first_name, name, role, insured_email, params[:person].present?)
    result.deliver_now
    puts result.to_s if Rails.env.development?
   end

  def find_hbx_profile
    @profile = current_user.person.try(:hbx_staff_role).try(:hbx_profile)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_hbx_profile
    @hbx_profile = HbxProfile.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def organization_params
    params[:hbx_profile][:organization].permit(:organization_attributes)
  end

  def hbx_profile_params
    params[:hbx_profile].permit(:hbx_profile_attributes)
  end

  def check_hbx_staff_role
    unless current_user.has_hbx_staff_role?
      redirect_to root_path, :flash => { :error => "You must be an HBX staff member" }
    end
  end

  def check_csr_or_hbx_staff
    unless current_user.has_hbx_staff_role? || (current_user.person.csr_role && !current_user.person.csr_role.cac)
      redirect_to root_path, :flash => { :error => "You must be an HBX staff member or a CSR" }
    end
  end

  def authorize_for_instance
    authorize @hbx_profile, "#{action_name}?".to_sym
  end

  def call_customer_service(first_name, last_name)
    "No match found for #{first_name} #{last_name}.  Please call Customer Service at: (855)532-5465 for assistance.<br/>"
  end
end

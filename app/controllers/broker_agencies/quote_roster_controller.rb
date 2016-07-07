class BrokerAgencies::QuoteRosterController < ApplicationController
	before_action :find_quote , :only => [:destroy ,:show, :delete_member, :delete_household, :publish_quote, :view_published_quote]
	before_action :format_date_params, :only => [:update,:create]
	before_action :employee_relationship_map

	def find_quote
    @quote = Quote.find(params[:id])
  end

  def format_date_params
	  params[:quote][:start_on] =  Date.strptime(params[:quote][:start_on],"%m/%d/%Y") if params[:quote][:start_on]
	  if params[:quote][:quote_households_attributes]
	    params[:quote][:quote_households_attributes].values.each do |household_attribute|
	      if household_attribute[:quote_members_attributes].present?
	        household_attribute[:quote_members_attributes].values.map { |m| m[:dob] = Date.strptime(m[:dob],"%m/%d/%Y") unless m[:dob] && m[:dob].blank?}
	      end
	    end
	  end
 end

  def destroy
    if @quote.destroy
      respond_to do |format|
        format.js { render :text => "deleted Successfully" , :status => 200 }
      end
    end
  end

  def show
    @quote = Quote.find(params[:id])
  end

	def edit
    #find quote to edits
    @quote = Quote.find(params[:id])

    # Create place holder for a new household and new member for the roster
    qhh = QuoteHousehold.new
    qm = QuoteMember.new
    qhh.quote_members << qm
    @quote.quote_households << qhh
  end

  def delete_member
    @qh = @quote.quote_households.find(params[:household_id])
    if @qh
      if @qh.quote_members.find(params[:member_id]).delete
        respond_to do |format|
          format.js { render :nothing => true}
        end
      end
    end
  end

	def new_household
    @quote = Quote.new
    @quote.quote_households.build
  end

  def delete_household
    @qh = @quote.quote_households.find(params[:household_id])
    if @qh.destroy
      respond_to do |format|
        format.js { render :nothing => true }
      end
    end
  end

	def new
    @quote = Quote.new
    qhh = QuoteHousehold.new
    qm = QuoteMember.new
    qhh.quote_members << qm
    @quote.quote_households << qhh
  end

  def update
    @quote = Quote.find(params[:id])

    sanitize_quote_roster_params

    update_params = quote_params
    insert_params = quote_params

    update_params[:quote_households_attributes] = update_params[:quote_households_attributes].select {|k,v| update_params[:quote_households_attributes][k][:id].present?}
    insert_params[:quote_households_attributes] = insert_params[:quote_households_attributes].select {|k,v| insert_params[:quote_households_attributes][k][:id].blank?}

    if (@quote.update_attributes(update_params) && @quote.update_attributes(insert_params))
      redirect_to edit_broker_agencies_quote_roster_path(@quote) ,  :flash => { :notice => "Successfully updated the employee roster" }
    else
      flash[:error]="Unable to update the employee roster"
      render "edit"
    end
  end

  def upload_employee_roster
  end

  def build_employee_roster
    @employee_roster = parse_employee_roster_file
    @quote= Quote.new
    if @employee_roster.is_a?(Hash)
      @employee_roster.each do |family_id , members|
        @quote_household = @quote.quote_households.where(:family_id => family_id).first
        @quote_household= QuoteHousehold.new(:family_id => family_id ) if @quote_household.nil?
        members.each do |member|
          @quote_members= QuoteMember.new(:employee_relationship => member[0], :dob => member[1], :first_name => member[2])
          @quote_household.quote_members << @quote_members
        end
        @quote.quote_households << @quote_household
      end
    end
  end

	def create
    @quote = Quote.new(quote_params)
    @quote.build_relationship_benefits
    @quote.broker_role_id= current_user.person(:try).broker_role.id
    if @format_errors.present?
      flash[:error]= "#{@format_errors.join(', ')}"
      render "new"  and return
    end
    if @quote.save
      redirect_to  broker_agencies_quotes_root_path ,  :flash => { :notice => "Successfully saved the employee roster" }
    else
      flash[:error]="Unable to save the employee roster : #{@quote.errors.full_messages.join(", ")}"
      render "new"
    end
  end

  private

  def quote_params
    params.require(:quote).permit(
                    :quote_name,
                    :start_on,
                    :broker_role_id,
                    :quote_households_attributes => [ :id, :family_id ,
                                       :quote_members_attributes => [ :id, :first_name, :last_name ,:dob,
                                                                      :employee_relationship,:_delete ] ] )
 	end

 	def employee_relationship_map
    @employee_relationship_map = {"employee" => "Employee", "spouse" => "Spouse", "domestic_partner" => "Domestic Partner", "child_under_26" => "Child"}
  end

	def format_date_params
	  @format_errors=[]
	  params[:quote][:start_on] =  Date.strptime(params[:quote][:start_on],"%m/%d/%Y") if params[:quote][:start_on]
	  if params[:quote][:quote_households_attributes]
	    params[:quote][:quote_households_attributes].values.each do |household_attribute|
	      if household_attribute[:quote_members_attributes].present?
	        household_attribute[:quote_members_attributes].values.map do |m|
	          begin
	            m[:dob] = Date.strptime(m[:dob],"%m/%d/%Y") unless m[:dob] && m[:dob].blank?
	          rescue Exception => e
	            @format_errors << "Error parsing date #{m[:dob]}"
	          end
	        end
	      end
	    end
	  end
	end
  
  def employee_roster_group_by_family_id
    params[:employee_roster].inject({}) do  |new_hash,e|
      new_hash[e[1][:family_id]].nil? ? new_hash[e[1][:family_id]] = [e[1]]  : new_hash[e[1][:family_id]] << e[1]
      new_hash
    end
  end

	def parse_employee_roster_file
    begin
      roster = Roo::Spreadsheet.open(params[:employee_roster_file])
      sheet = roster.sheet(0)
      sheet_header_row = sheet.row(1)
      column_header_row = sheet.row(2)
      census_employees = {}
      (4..sheet.last_row).each_with_index.map do |i, index|
        row = roster.row(i)
        row[1]="child_under_26" if row[1].split.join('_').downcase == "disabled_child"|| row[1].downcase == "child"
        if census_employees[row[0].to_i].nil?
          census_employees[row[0].to_i] = [[row[1].split.join('_').downcase,row[8],row[2]]]
        else
          census_employees[row[0].to_i] << [row[1].split.join('_').downcase,row[8],row[2]]
        end
      end
      census_employees
    rescue Exception => e
      puts e.message
      flash[:error] = "Unable to parse the csv file"
      #redirect_to :action => "new" and return
    end
  end

  def sanitize_quote_roster_params
		params[:quote][:quote_households_attributes].each do |key, fid|
			params[:quote][:quote_households_attributes].delete(key) if fid['family_id'].blank?
		end
 	end

end

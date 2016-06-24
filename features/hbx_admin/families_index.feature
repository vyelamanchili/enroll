Feature: HBX-Admin navigates to landing page
	As an HBX admin, I want to be able to navigate to the families
	link through the admin portal

	Scenario: HBX-Admin navigates to families link
		Given I am an HBX admin
		When I navigate to the admin portal
		And click on the Families link
		Then I am taken to the families index page
		And cancellation and termination are action options in the dropdown column


	Scenario: select cancellation from the dropdown list
		Given I need to cancel an enrollment
		When I select cancellation from the dropdown list
		#verify verbage with Holly/Chip
		Then a new box appears under the active row
		And I see the field Plan name
		#effective start date state? 
		And I see the Effective Start Date	
		And I see the cancellation end date
		And the end date is set to the effective start date
		#is non-actionable the right term?
		And it is non-actionable
		And the checkbox for EDI Transmission to Carriers is checked
		And I see a submit button

	Scenario: select cancellation from the dropdown list
		Given I need to terminate an enrollment
		When I select terminate from the dropdown list
		#verify verbage with Holly/Chip
		Then a new box appears under the active row
		And I see the field Plan name
		#effective start date state? 
		And I see the Effective Start Date	
		And I see the termination end date
		And the end date is set to the current date
		#is actionable the right term?
		And it is actionable
		# only relative to the present day, right?
		And the termination end date can be set to a past date
		And the termination end date can be set to a future date
		And the checkbox for EDI Transmission to Carriers is checked
		And I see a submit button	

	Scenario: uncheck the EDI transmission to carriers checkbox
		Given I have selected an enrollment for cancellation or termination
		When I uncheck the checkbox for EDI Transmission to Carrier
		#how will this be displayed? pop-up, modal...
		Then a modal window will pop-up
		#should there be a confirmation of understanding button in the pop-up
		And it contains the text 
		"""
		Warning: Are you SURE that youwat to term/cancel without
		transmiting to carrier? This should only be used if the carrier either (a) already 
		processed the term/cancel, or (b) if the carrier never processed the enrollment
		"""
		And I click submit
		# will there be a text confirming successful completion and do we jsut remain on the
		# the families index
		Then the term/cancell is complete

	# not sure if this is a test suitable for cucumber	
	Scenario: 	HBX-Admin receives report of terminations/cancellations that need EDI transmission
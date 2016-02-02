Given /(\w+) is a person/ do |name|
  @a = Time.now unless @a
  person = FactoryGirl.create(:person, first_name: name)
  @pswd = 'aA1!aA1!aA1!'
  user = User.create(email: Forgery('email').address, password: @pswd, password_confirmation: @pswd, person: person)
  instance_variable_set '@'+name, person
end


Then(/(\w+) is the staff person for an employer/) do |person|
  person = instance_variable_get '@'+person
  employer_profile = FactoryGirl.create(:employer_profile)
  employer_staff_role = FactoryGirl.create(:employer_staff_role, person: person, employer_profile_id: employer_profile.id)
end

When(/(\w+) accesses the Employer Portal/) do |person|
  person = instance_variable_get '@' + person
  @browser.goto("http://localhost:3000/")
  portal_class = 'interaction-click-control-employer-portal'
  @browser.a(class: portal_class).wait_until_present
  @browser.a(class: portal_class).click
  @browser.element(class: /interaction-click-control-sign-in-existing-account/).wait_until_present
  @browser.element(class: /interaction-click-control-sign-in-existing-account/).click
  @browser.text_field(class: /interaction-field-control-user-email/).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).set(person.user.email)
  @browser.text_field(class: /interaction-field-control-user-password/).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-password/).set(@pswd)
  @browser.element(class: /interaction-click-control-sign-in/).click
  @browser.element(class: /interaction-click-control-sign-in/).wait_while_present
  end


Then /(\w+) edits Business information/ do |person|
  @browser.a(class: /interaction-click-control-update-business-info/).wait_until_present
  @browser.a(class: /interaction-click-control-update-business-info/).click
end

Given /(\w+) adds an EmployerStaffRole to (\w+)/ do |staff, new_staff|
  person = instance_variable_get '@' + new_staff
  button_class = 'interaction-click-control-add-employer-staff-role'
  @browser.element(class: button_class).wait_until_present
  @browser.element(class: button_class).click
  first_field = 'interaction-field-control-first-name'
  last_field = 'interaction-field-control-last-name'
  dob_field = 'interaction-field-control-dob'
  expect(@browser.trs.count).to eq(2)
  @browser.element(class: first_field).wait_until_present
  @browser.text_field(class: first_field).set(person.first_name)
  @browser.text_field(class: last_field).set(person.last_name)
  @browser.text_field(class: dob_field).set(person.dob)
  @browser.button(class: 'interaction-click-control-save').click
end

Then /Point of Contact count is (\d+)/ do |count|
  @browser.tbody.wait_until_present
  rows = @browser.tbody.trs.count
  expect(rows).to eq(count.to_i)
  screenshot('point_of_contact')
end

When /EmployerStaff removes EmployerStaffRole from (\w+)/ do |staff|
  person = instance_variable_get '@' + staff
  @browser.link(id: @new_staff.id.to_s).click
end

When /(\w+) removes EmployerStaffRole from (\w+)/ do |staff1, staff2|
  staff = instance_variable_get "@"+staff2 
  @browser.link(id: staff.id.to_s).click
end

Then /(\w+) sees new employer page/ do |ex_staff|
  @browser.h2(text: /Thank you for logging into/).wait_until_present
  match = @browser.url.match  /employers\/employer_profiles\/new/        
  expect(match.present?).to be_truthy
end
Then /show elapsed time/  do
  puts Time.now - @a
end

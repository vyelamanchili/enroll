Capybara.ignore_hidden_elements = false

module BrokerWorld
  def broker(*traits)
    attributes = traits.extract_options!
    @broker ||= FactoryGirl.create :user, *traits, attributes
  end

  def broker_agency(*traits)
    attributes = traits.extract_options!
    @broker_agency ||= FactoryGirl.create :broker , *traits, attributes
  end

end

World(BrokerWorld)

Given (/^that a broker exists$/) do
  broker_agency
  broker :with_family, :broker_with_person, organization: broker_agency
end

And(/^the broker is signed in$/) do
  login_as broker, scope: :user
end

When(/^he visits the Roster Quoting tool$/) do
  visit broker_agencies_root_path
  click_link 'Roster Quoting Tool'
end

Then(/^click on QuoteRoster Management$/) do
  click_link 'Quote/Roster Management'
end

When(/^click on the New Quote button$/) do
  click_link 'New Quote'
end


When(/^click on the Upload Employee Roster button$/) do
  click_link "Upload Employee Roster"
end

When(/^the broker clicks on the Select File to Upload button$/) do
  within '.upload_csv' do
    attach_file('employee_roster_file', "#{Rails.root}/spec/test_data/employee_roster_import/Employee_Roster_sample.csv")
    find('html div#modal-wrapper div.employee-upload form.upload_csv input.btn.btn-primary.btn-br').trigger("click")
  end
end

Then(/^the broker should see the data in the table$/) do
  expect(page).to have_selector("input#quote_quote_households_attributes_0_family_id[value=\"1\"]")
  expect(page).to have_selector("input#quote_quote_households_attributes_1_family_id[value=\"2\"]")
  expect(page).to have_selector('div.panel.panel-default div input.uidatepicker', count: 4)
  expect(page).to have_selector("#quote_quote_households_attributes_0_quote_members_attributes_0_dob[value=\"03/14/2016\"]")
end

When(/^broker clicks on Add member to this family$/) do
  click_button 'Add member to this family'
end

When(/^the broker enters Family ID$/) do
  fill_in 'quote_households_family_id', with: '2'
end

When(/^broker enters valid information$/) do
  select "Employee", :from => "select-relationship"
  fill_in 'date-of-birth', with: '11/11/1991'
end

When(/^the broker clicks on the Save Quote button$/) do
  find('.interaction-click-control-save-quote').click
end

Then(/^the broker should see a successful message$/) do
  expect(page).to have_content('Successfully saved the employee roster')
end


When(/^the broker clicks on the close button$/) do
  find(:xpath, "//table//button[contains(@id, 'close_button')]").click
end

Then(/^the Quote should be deleted$/) do
  page.should have_no_xpath("//table//input[contains(@id, 'family_id')]")
end

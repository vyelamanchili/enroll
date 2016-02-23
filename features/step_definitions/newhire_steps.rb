def people
  return @a if defined?(@a)
  @a = {
    "Jack Ivl" => {
      first_name: "Jack",
      last_name: "Ivl",
      dob: "08/10/1960",
      ssn: "196008107",
      email: "jack@ivl.com",
      password: 'aA1!aA1!aA1!'

    },
    "Jack Doe" => {
      first_name: "Jack",
      last_name: "Doe",
      dob: '10/11/1978',
      legal_name: "BestLife",
      dba: "BestLife",
      fein: "050000000",
      ssn: "197810118",
      email: "jack@dc.gov",
      password: 'aA1!aA1!aA1!'
    },
  }
end

When(/^(.*) create a new account$/) do |named_person|
  person = people[named_person]
  @browser.text_field(name: "user[password_confirmation]").wait_until_present
  @browser.text_field(name: "user[email]").set(person[:email])
  @browser.text_field(name: "user[password]").set(person[:password])
  @browser.text_field(name: "user[password_confirmation]").set(person[:password])
  screenshot("create_account")
  scroll_then_click(@browser.input(value: "Create account"))
end

When(/^(.*) goes to register as an individual$/) do |named_person|
  person = people[named_person]
  @browser.button(class: /interaction-click-control-continue/).wait_until_present
  @browser.text_field(class: /interaction-field-control-person-first-name/).set(person[:first_name])
  @browser.text_field(class: /interaction-field-control-person-last-name/).set(person[:last_name])
  @browser.p(text: /suffix/i).click
  suffix = @browser.element(class: /selectric-scroll/)
  suffix.wait_until_present
  suffix = @browser.element(class: /selectric-scroll/)
  suffix.li(text: /Jr./).click
  @browser.text_field(class: /interaction-field-control-jq-datepicker-ignore-person-dob/).set(person[:dob])
  @browser.h1(class: /darkblue/).click
  @browser.text_field(class: /interaction-field-control-person-ssn/).set(person[:ssn])
  @browser.text_field(class: /interaction-field-control-person-ssn/).click
  expect(@browser.text_field(class: /interaction-field-control-person-ssn/).value).to_not eq("")
  @browser.checkbox(class: /interaction-choice-control-value-person-no-ssn/).fire_event("onclick")
  expect(@browser.text_field(class: /interaction-field-control-person-ssn/).value).to eq("")
  @browser.text_field(class: /interaction-field-control-person-ssn/).set(person[:ssn])
  @browser.radio(class: /interaction-choice-control-value-radio-male/).fire_event("onclick")
  screenshot("register")
end

And(/^(.*) click on purchase button on confirmation page/) do |named_person|
  person = people[named_person]
  click_when_present(@browser.checkbox(class: /interaction-choice-control-value-terms-check-thank-you/))
  @browser.text_field(class: /interaction-field-control-first-name-thank-you/).set(person[:first_name])
  @browser.text_field(class: /interaction-field-control-last-name-thank-you/).set(person[:last_name])
  screenshot("purchase")
  click_when_present(@browser.a(text: /confirm/i))
end

Then(/^.+ should see a form to enter information about employee, address and dependents details for (.*)$/) do |named_person|
  person = people[named_person]
  @browser.text_field(class: /interaction-field-control-census-employee-first-name/).wait_until_present
  @browser.text_field(class: /interaction-field-control-census-employee-first-name/).set(person[:first_name])
  @browser.text_field(class: /interaction-field-control-census-employee-last-name/).set(person[:last_name])
  @browser.p(text: /suffix/i).click
  suffix = @browser.element(class: /selectric-scroll/)
  suffix.wait_until_present
  suffix = @browser.element(class: /selectric-scroll/)
  suffix.li(text: /Jr./).click
  @browser.h1(text: /Add New Employee/i).click

  @browser.text_field(class: /interaction-field-control-jq-datepicker-ignore-census-employee-dob/).set(person[:dob])
  @browser.text_field(class: /interaction-field-control-census-employee-ssn/).set(person[:ssn])
  @browser.radio(id: /radio_male/).fire_event("onclick")
  @browser.text_field(class: /interaction-field-control-jq-datepicker-ignore-census-employee-hired-on/).set((TimeKeeper.date_of_record - 10.days).to_s)
  @browser.p(text: /Silver PPO Group/i).click
  @browser.li(text: /Silver PPO Group/).click

  # Address
  @browser.text_field(class: /interaction-field-control-census-employee-address-attributes-address-1/).wait_until_present
  @browser.text_field(class: /interaction-field-control-census-employee-address-attributes-address-1/).set("1026 Potomac")
  @browser.text_field(class: /interaction-field-control-census-employee-address-attributes-address-2/).set("apt abc")
  @browser.text_field(class: /interaction-field-control-census-employee-address-attributes-city/).set("Alpharetta")
  select_state = @browser.divs(text: /SELECT STATE/).last
  select_state.click
  scroll_then_click(@browser.li(text: /GA/))
  @browser.text_field(class: /interaction-field-control-census-employee-address-attributes-zip/).set("30228")
  email_kind = @browser.divs(text: /SELECT KIND/).last
  email_kind.click
  @browser.li(text: /home/).click
  @browser.text_field(class: /interaction-field-control-census-employee-email-attributes-address/).set(person[:email])

  screenshot("create_census_employee_with_data")
  @browser.element(class: /interaction-click-control-create-employee/).click
end

And(/^.+ should see employer census family created success message for (.*)$/) do |named_person|
  sleep(1)
  person = people[named_person]
  expect(@browser.div(text: /successfully/).visible?).to be_truthy
  screenshot("employer_census_new_family_success_message")
  @browser.refresh
  @browser.a(text: /Employees/).wait_until_present
  @browser.a(text: /Employees/).click
  @browser.a(text: /#{person[:first_name]} #{person[:last_name]} Jr/).wait_until_present
  expect(@browser.a(text: /#{person[:first_name]} #{person[:last_name]} Jr/).visible?).to be_truthy
end

And(/^.+ should be able to enter plan year, benefits, relationship benefits$/) do
  @browser.div(class: /selectric-interaction-choice-control-plan-year-start-on/).wait_until_present
  start_on = @browser.div(class: /selectric-interaction-choice-control-plan-year-start-on/)
  start_on.fire_event('onclick')
  start_on.li(index: 1).fire_event('onclick')
  screenshot("employer_add_plan_year")
  @browser.text_field(name: "plan_year[fte_count]").fire_event('onclick')
  @browser.text_field(name: "plan_year[fte_count]").set("35")
  @browser.text_field(name: "plan_year[pte_count]").set("15")
  @browser.text_field(name: "plan_year[msp_count]").set("3")
  @browser.a(class: /interaction-click-control-continue/).wait_until_present
  @browser.a(class: /interaction-click-control-continue/).fire_event('onclick')

  # Benefit Group
  @browser.text_field(name: "plan_year[benefit_groups_attributes][0][title]").set("Silver PPO Group")
  select_field = @browser.div(class: /selectric-wrapper/, text: /Date Of Hire/)
  select_field.click
  select_field.li(text: /Date of hire/i).click
  @browser.text_field(name: "plan_year[benefit_groups_attributes][0][relationship_benefits_attributes][0][premium_pct]").set(50)
  @browser.text_field(name: "plan_year[benefit_groups_attributes][0][relationship_benefits_attributes][1][premium_pct]").set(50)
  @browser.text_field(name: "plan_year[benefit_groups_attributes][0][relationship_benefits_attributes][2][premium_pct]").set(50)
  @browser.text_field(name: "plan_year[benefit_groups_attributes][0][relationship_benefits_attributes][3][premium_pct]").set(50)
  select_plan_option = @browser.ul(class: /nav-tabs/)
  select_plan_option.li(text: /By carrier/i).click
  carriers_tab = @browser.div(class: /carriers-tab/)
  sleep(3)
  carriers_tab.as[1].fire_event("onclick")
  plans_tab = @browser.div(class: /reference-plans/)
  sleep(3)
  plans_tab.labels.last.fire_event('onclick')
  sleep(3)

  @browser.button(class: /interaction-click-control-create-plan-year/).click
end

And(/Employer should see the status of employee role linked/) do
  expect(@browser.text.include?("Employee Role Linked")).to be_truthy
end

Then(/^(.*) login$/) do |named_person|
  person = people[named_person]
  wait_and_confirm_text(/Sign In Existing Account/)
  click_when_present(@browser.link(class: /interaction-click-control-sign-in-existing-account/))
  @browser.h1(text: "Sign In").wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).set(person[:email])
  @browser.text_field(class: /interaction-field-control-user-password/).set(person[:password])
  @browser.element(class: /interaction-click-control-sign-in/).click
end

Then(/I should see a successful sign in message/) do
  wait_and_confirm_text(/My DC Health Link/)
  expect(@browser.text.include?("Signed in successfully.")).to be_truthy
end

And(/I should see employer hire message/) do
  expect(@browser.text.include?("Congratulations on your new job at BestLife.")).to be_truthy
  expect(@browser.input(value: /Shop for Employer Sponsored Coverage/).visible?).to be_truthy
  @browser.input(value: /Shop for Employer Sponsored Coverage/).click
end

And(/I should not see employer hire message/) do
  expect(@browser.text.include?("Congratulations on your new job at BestLife.")).to be_falsey
end

And(/^Jack Ivl click on continue button on group selection page after hired by employer$/) do
  click_when_present(@browser.button(class: /interaction-click-control-continue/))
end

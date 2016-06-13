Feature: Create Employee Roster
  In order for Brokers to give a quote to employees
  The Broker should be able to add emloyees
  And Generate a quote

  Scenario: Broker should be able to add employee to employee roster
    Given that a broker exists
    And the broker is signed in
    When he visits the Roster Quoting tool
    Then click on QuoteRoster Management
    And click on the New Quote button
    When broker clicks on Add member to this family
    And broker enters valid information

  Scenario: Broker should be able to add employees to the employee roster using Upload Employee Roster button
    Given that a broker exists
    And the broker is signed in
    When he visits the Roster Quoting tool
    Then click on QuoteRoster Management
    And click on the New Quote button
    And click on the Upload Employee Roster button
    When the broker clicks on the Select File to Upload button
    And the broker should see the data in the table

  Scenario: Broker should be able to Save the Roster
    Given that a broker exists
    And the broker is signed in
    When he visits the Roster Quoting tool
    Then click on QuoteRoster Management
    And click on the New Quote button
    When broker clicks on Add member to this family
    And broker enters valid information
    When the broker clicks on the Save Quote button
    Then the broker should see a successful message

  Scenario: Broker should be able to delete an existing Quote
    Given that a broker exists
    And the broker is signed in
    When he visits the Roster Quoting tool
    Then click on QuoteRoster Management
    And click on the New Quote button
    When the broker clicks on the Save Quote button
    Then the broker should see a successful message
    Then click on QuoteRoster Management
    When the broker clicks on the close button
    Then the Quote should be deleted

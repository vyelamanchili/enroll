Feature: Employer can terminate their census employees

  Scenario: Employer terminates a census employees
    Given an employer exists
    And the employer has employees
    And the employer is logged in
    When they visit the Employee Roster
    And they click on the terminate employee icon
    Then they enter a termination date for the employee
    When the employer clicks the terminate employee button
    Then the employer should see the confirm termination modal
    When the employer clicks the confirm termination button
    Then the employer sees successful termination message
    And employer logs out

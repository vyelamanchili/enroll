@watir @screenshots
Feature: Employer Profile
  In order for employers to manage their accounts
  Employer Staff should be able to add and delete employer staff roles
  
  Scenario: An existing person asks for a staff role at an existing company
    Given Hannah is a person
    Given Hannah is the staff person for an employer
    Given BusyGuy is a person
    Given BusyGuy accesses the Employer Portal

    Given BusyGuy selects Turner Agency, Inc from the dropdown
    Then BusyGuy is notified about Employer Staff Role pending status
    Then BusyGuy logs out
    When Hannah accesses the Employer Portal
    And Hannah decides to Update Business information
    Then Point of Contact count is 2

  Scenario: An employer staff adds two roles and deletes one
    Given Sarah is a person
    Given Hannah is a person
    Given Hannah is the staff person for an employer
    When Hannah accesses the Employer Portal
    And Hannah decides to Update Business information
    Then Point of Contact count is 1

    Then Hannah cannot remove EmployerStaffRole from Hannah
    Then Point of Contact count is 1
    When Hannah adds an EmployerStaffRole to Sarah
    Then Point of Contact count is 2
    When Hannah removes EmployerStaffRole from Sarah
    Then Point of Contact count is 1

    When Hannah adds an EmployerStaffRole to Sarah
    Then Point of Contact count is 2

    When Hannah removes EmployerStaffRole from Hannah
    Then Hannah sees new employer page
    Then Hannah logs out

    When Sarah accesses the Employer Portal
    And Sarah decides to Update Business information
    Then Point of Contact count is 1
    Then Sarah logs out
    Then show elapsed time
@wip
  Scenario: A new person asks for a staff role at an existing company
    Given Hannah is a person
    Given Hannah is the staff person for an employer
    Given HRDirector accesses the Employer Portal
    Given HRDirector selects Turner Agency, Inc from the dropdown
@watir @screenshots
Feature: Claim Employer
  In order for employers to operate on the exchange
  An Employee Representative must be able to claim an existing employer

    Scenario: An existing, unclaimed employer
      Given an existing employer
      And the employer is unclaimed
      And I have logged in as a user
      When I visit the employer sign-up page
      And I complete the employer sign up page with the information for the employer
      Then I should match that employer

    Scenario: An existing employer who has already been claimed
      Given an existing employer
      And the employer has been claimed
      And I have logged in as a user
      When I visit the employer sign-up page
      And I complete the employer sign up page with the information for the employer
      Then I should be prevented from matching that employer

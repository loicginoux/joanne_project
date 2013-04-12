Feature: Register a new user
  In order to start using the app
  As a visitor of the site
  I want to create a new account


Scenario: Register as a new user
  Given I am on the register page
  When  I enter the register credentials with the email "test@test.com"
  And I click "Create account"
  Then the alert message should be "Thanks for signing up. Check your email at test@test.com to complete the sign-up process."


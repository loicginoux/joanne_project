Feature: Signing In
  In order to use the application
  As a registered user
  I want to sign in through a form

Scenario: Signing in through the form
  Given I am a registered user
  And I am on the sign in page
  When I enter correct login credentials
  And I click "Log in"
  Then you should land on your diary page


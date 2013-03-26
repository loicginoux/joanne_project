Feature: Signing In
  In order to use the application
  As a registered user
  I want to sign in through a form

Scenario: Signing in through the form
  Given there is a registered user with email "user@example.com"
  And I am on the sign in page
  When I enter correct credentials
  And I press the sign in button
  Then you should land on your diary page
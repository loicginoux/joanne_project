Feature: recover my password
  In order that I can login in the app
  As a registered user
  I want to recover my password


Scenario: sending the password recovery email
  Given I am on the lost password page
  And I am a registered user with email "test@test.com"
  When I provide the form with my email
  And I click "Reset my password"
  Then the alert message should be "Instructions to reset your password have been emailed to test@test.com. Please check your email."

Scenario: changing my password and log in
  Given I am a registered user
  And I require a new password
  When I go to the link provided in the recovery password email
  And I change my password
  And I click "Update my password and log me in"
  Then you should land on your diary page
  And the alert message should be "Password successfully updated"
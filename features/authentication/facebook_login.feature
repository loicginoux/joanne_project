Feature: Login with Facebook
  In order to Login with a Facebook account
  As a Facebook user
  I want to be able to login in one step

Scenario: Login with Facebook
  Given I am on the sign in page
  And I am registered as a Facebook user
  When I click "auth_provider"
  Then you should land on your diary page

Scenario: Registering with Facebook
  Given I am on the sign in page
  And  I click "auth_provider"
  Then  You should land on the register page
  And you should see the message "You have been authenticated via Facebook. Please complete your registration below."

Scenario: add Facebook details for registering
  Given I login with facebook
  When I fill the password fields
  And I click "Create account"
  Then you should land on your diary page

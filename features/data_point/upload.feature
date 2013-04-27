@javascript
Feature: Uploading a new photo
  In order to add photo's to my diary
  As a registered user
  I want to upload photo to the app

Scenario: Uploading from the app
  Given I am a registered user
  And I login
  When I click on upload button
  And I fill in the photo's form with 123 calories
  And I submit the upload form
  Then I should have the photo with 123 calories


@javascript
Feature: Commenting on a photo
  In order that I comment on a photo
  As a registered user
  I want to comment on photos

Background:
	Given I am a registered user with photos
	And I login

Scenario: Comment on photo
	Given I click on the photo of the diary page
	When I comment the photo with comment "test comment"
	Then I should see the comment with the text "test"
	When I edit the comment with "test 2"
  Then I should see the comment with the text "test 2"
  When I delete the comment
  Then I shouldn't find any comment

  Given I am on the page of a photo
  When I comment the photo with comment "test comment"
  Then I should see the comment with the text "test comment"
  When I edit the comment with "test 2"
  Then I should see the comment with the text "test 2"
  When I delete the comment
  Then I shouldn't find any comment

  Given I am on the feed page
  When I comment the photo with comment "test comment"
  Then I should see the comment with the text "test comment"
  When I edit the comment with "test 2"
  Then I should see the comment with the text "test 2"
  When I delete the comment
  Then I shouldn't find any comment
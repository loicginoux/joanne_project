@javascript
Feature: Liking a photo
  In order that someone can like a photo
  As a registered user
  I want to like a photo

Background:
	Given I am a registered user with photos
	And I login

Scenario: Liking/Unliking a photo
  Given I click on the photo of the diary page
  When I like the photo
  Then I should see the text " Unlike" on the like button
	When I unlike the photo
	Then I should see the text " Like" on the like button

	Given I am on the page of a photo
  When I like the photo
  Then I should see the text " Unlike" on the like button
	When I unlike the photo
	Then I should see the text " Like" on the like button

  Given I am on the feed page
  When I like the photo
  Then I should see the text " Unlike" on the like button
	When I unlike the photo
	Then I should see the text " Like" on the like button
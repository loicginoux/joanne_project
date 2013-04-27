@javascript
Feature: Editing a photo
  In order that I can adjust the information on a photo
  As a registered user
  I want to edit my photos

Background:
	Given I am a registered user with photos
	And I login

Scenario: Editing my photos
	Given I click on the photo of the diary page
  And I edit the photo
  When  I set "432" in "#modal_view .calories input"
  And I set "04-02-2013" in "#modal_view .date input"
  And I set "03:19 pm" in "#modal_view .time input"
  And I set "test desc" in "#modal_view .description input"
  And I change the photo to "test2.png"
  And I click "Save changes"
	Given I click on the photo of the diary page
	Then I see "Description: test desc" in "p.description"
	Then I see "Calories: 432 calories" in "p.calories"
	Then I see "Date: 04-02-2013 03:19 pm" in "p.date"

  Given I am on the page of a photo
  And I edit the photo
  When  I set "222" in "#data_point_calories"
  And I set "04-02-2013" in ".date input"
  And I set "03:19 pm" in ".time input"
  And I set "Lorem" in ".description input"
  And I change the photo to "test2.png"
  And I click "Save changes"
	Then I see "Description: Lorem" in "p.description"
	Then I see "Calories: 222 calories" in "p.calories"
	Then I see "Date: 04-02-2013 03:19 pm" in "p.date"

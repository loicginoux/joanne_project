Feature: Change diary's period
  In order to visualize my activity
  As a registered user
  I want to be see my diary in different periods


Background:
	Given I am a registered user with photos
	And I login

@javascript
Scenario: changing to month view
  Given I am in the diary's page
  When I go to today
  Then the current week should be displayed
  When  I change to "Month" view
  Then  the current month should be displayed
  When I change to previous month
  Then  the previous month should be displayed
  When I change to next month
	Then  the current month should be displayed
	When  I change to "Week" view
  Then the current week should be displayed
	When I change to previous week
	Then  the previous week should be displayed
	When I change to next week
	Then the current week should be displayed
	When  I change to "Day" view
	Then  the current day should be displayed
	When I change to previous day
	Then  the previous day should be displayed
	When I change to next day
	Then the current day should be displayed

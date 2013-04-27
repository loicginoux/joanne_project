
Given(/^I am in the diary's page$/) do
  visit user_path(:username=> @user.username)
end


When(/^I change to "(.*?)" view$/) do |period|
  click_on period
end

When(/^I change to next (.*?)$/) do |period|
	page.should have_selector("#photos h2")
  page.first(".next").click
end

When(/^I change to previous (.*?)$/) do |period|
	page.should have_selector("#photos h2")
  page.first(".prev").click
end

When(/^I go to today$/) do
  click_on "Today"
end

Then(/^the current month should be displayed$/) do
	find('#photos').find("h2").should have_content Date.today.strftime("%B %Y")
end

Then(/^the previous month should be displayed$/) do
	now = DateTime.now - 1.month
	find('#photos').find("h2").should have_content now.strftime("%B %Y")
end

Then(/^the next month should be displayed$/) do
	now = DateTime.now + 1.month
	find('#photos').find("h2").should have_content now.strftime("%B %Y")
end

Then(/^the current week should be displayed$/) do
	now = DateTime.now
	lastSunday = now.beginning_of_week(:sunday)
	nextSaturday = now.end_of_week(:sunday)
	current_week = "#{lastSunday.strftime('%b %e')} - #{nextSaturday.strftime('%b %e %Y')}"
	find('#photos').find("h2").should have_content current_week
end

Then(/^the previous week should be displayed$/) do
	now = DateTime.now - 1.week
	lastSunday = now.beginning_of_week(:sunday)
	nextSaturday = now.end_of_week(:sunday)
	current_week = "#{lastSunday.strftime('%b %e')} - #{nextSaturday.strftime('%b %e %Y')}"
	find('#photos').find("h2").should have_content current_week
end

Then(/^the next week should be displayed$/) do
	now = DateTime.now + 1.week
	lastSunday = now.beginning_of_week(:sunday)
	nextSaturday = now.end_of_week(:sunday)
	current_week = "#{lastSunday.strftime('%b %e')} - #{nextSaturday.strftime('%b %e %Y')}"
	find('#photos').find("h2").should have_content current_week
end

Then(/^the current day should be displayed$/) do
	find('#photos').find("h2").should have_content Date.today.strftime("%a %e %B %Y")
end

Then(/^the next day should be displayed$/) do
	find('#photos').find("h2").should have_content Date.tomorrow.strftime("%a %e %B %Y")
end

Then(/^the previous day should be displayed$/) do
	find('#photos').find("h2").should have_content Date.yesterday.strftime("%a %e %B %Y")
end
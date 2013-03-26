Given(/^there is a registered user with email "(.*?)"$/) do |arg1|
	@user = FactoryGirl.create(:user)
end

Given(/^I am on the sign in page$/) do
	visit login_path
end

When(/^I enter correct credentials$/) do
	fill_in "user_session_username", with: @user.username
  fill_in "user_session_password", with: @user.password
end

When(/^I press the sign in button$/) do
  click_button "Log in"
end

Then(/^you should land on your diary page$/) do
  URI.parse(current_url).path.should_not == login_path
end
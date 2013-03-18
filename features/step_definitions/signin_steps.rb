Given(/^there is a registered user with email "(.*?)"$/) do |arg1|
	@user = FactoryGirl.create(:user)
end

Given(/^I am on the sign in page$/) do
	visit login_path
end

When(/^I enter correct credentials$/) do
	fillin "Email", with: @user.email
  fillin "Password", with: @user.password
end

When(/^I press the sign in button$/) do
  click_button "Sign in"
end

Then(/^the flash message should be "(.*?)"$/) do |arg1|
  within(".flash") do
    page.should have_content text
  end
end
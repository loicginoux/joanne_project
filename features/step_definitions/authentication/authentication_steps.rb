Given(/^I am on the register page$/) do
	visit register_path()
end

Given(/^I am on the lost password page$/) do
	visit lost_password_path()
end

Given(/^I am on the sign in page$/) do
	visit login_path
end

Given(/^I require a new password$/) do
	send_password_recovery_email(@user)
end

When(/^I enter the register credentials with the email "(.*?)"$/) do |email|
	fill_in "user_username", with: "tester"
	fill_in "user_email", with: email
	fill_in "user_password", with: "password"
	fill_in "user_password_confirmation", with: "password"
end

When(/^I fill the password fields$/) do
	fill_in "user_password", with: "password"
	fill_in "user_password_confirmation", with: "password"
end

When(/^I enter correct login credentials$/) do
	fill_in "user_session_username", with: @user.username
  fill_in "user_session_password", with: @user.password
end

When(/^I provide the form with my email$/) do
  fill_in "email", with: @user.email
end


When(/^I go to the link provided in the recovery password email$/) do
	visit edit_password_reset_url(User.find(@user.id).perishable_token)
end

When(/^I change my password$/) do
		fill_in "user_password", with: "new_password"
		fill_in "user_password_confirmation", with: "new_password"
end



Then(/^you should land on your diary page$/) do
	@user = User.last unless @user
  current_path.should == "/"+ @user.username
end


Then(/^You should land on the register page$/) do
  current_path.should == register_path
end


Then(/^you should see the message "(.*?)"$/) do |msg|
	within(".alert p:first") do
	  page.should have_content text
	end
end


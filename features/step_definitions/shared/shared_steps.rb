Given(/^I am a registered user$/) do
	@user = FactoryGirl.create(:user)
end

Given(/^I am a registered user with photos$/) do
	@user = FactoryGirl.create(:user_with_data_points)
end

Given(/^I am a registered user with email "(.*?)"$/) do |email|
	@user = FactoryGirl.create(:user, :email => email)
end

Given(/^I am registered as a Facebook user$/) do
  @user = FactoryGirl.create(:user)
  omniauth = OmniAuth.config.mock_auth[:facebook]
  @user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :username => omniauth['extra']['raw_info']['username'] , :access_token => omniauth["credentials"]['token'])
  @user.save
end

Given(/^I am on the page of a photo$/) do
  visit data_point_path(DataPoint.last)
end

Given(/^I am on the feed page$/) do
  visit feed_path
end

Given(/^I am on the diary page$/) do
	visit user_path(:username=> @user.username)
end

Given(/^I login with facebook$/) do
  login_with_oauth()
end

Given(/^I login$/) do
  login_for_user(@user)
end

Given(/^I click on the photo of the diary page$/) do
	begin
		element = find("#image_#{DataPoint.last.id} img")
		element.click
	rescue => e
		sleep 10
		el = find("#image_#{DataPoint.last.id} img")
		el.click
	end
end



Then(/^the alert message should be "(.*?)"$/) do |text|
	within(".flash-error") do
	  page.should have_content text
	end
end


When(/^I click "(.*?)"$/) do |button|
	click_on button
end

Then(/^I see "(.*?)" in "(.*?)"$/) do |text, selector|
  begin
		find(selector).should have_content text
	rescue => e
		sleep 5
		find(selector).should have_content text
	end

end

Then(/^I set "(.*?)" in "(.*?)"$/) do |text, selector|
  find(selector).set text
end

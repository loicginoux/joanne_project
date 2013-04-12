When(/^I click on upload button$/) do
	page.first(".upload_btn").click
end

When(/^I fill in the photo's form with (.*?) calories$/) do |calories|
	fill_in "data_point_calories", with: calories
	fill_in "data_point_description", with: "description test"
	page.execute_script("$('#ifu').removeClass('hide')")
	within_frame "ifu" do
		attach_file("fileInput", Rails.root + 'spec/fixtures/images/test1.png')
	end
end

When(/^I submit the upload form$/) do
	find("#new_upload .btn-save").click
end

Then(/^I should have the photo with (.*?) calories$/) do |calories|
	debugger
  page.should have_selector(".image")
  find(".image .nbCalories").should have_content calories
end



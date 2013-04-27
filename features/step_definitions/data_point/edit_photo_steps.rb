When(/^I edit the photo$/) do
  find(".btn-edit").click
end

When(/^I change date to "(.*?)" (.*?)$/) do |text, modal_view|
  find(".date input").set(text)
end

When(/^I change calories to "(.*?)"$/) do |text|
  find(".calories input").set(text)
end

When(/^I change time to "(.*?)"$/) do |text|
  find("#timePicker_#{DataPoint.last.id}").set(text)
end

When(/^I change description to "(.*?)"$/) do |text|
  find("#data_point_description").set(text)
end


When(/^I change the date to first of next month$/) do
	# open date picker
  find(".date input").click
	# chagne to first of next month
  find(".datepicker .day.new:first").click
end

When(/^I change the photo to "(.*?)"$/) do |image|
  page.execute_script("$('#ifu_#{DataPoint.last.id}').removeClass('hide')")
	id = DataPoint.last.id
	within_frame "ifu_#{id}" do
		attach_file("fileInput_#{id}", Rails.root + 'spec/fixtures/images/' + image)
	end
end



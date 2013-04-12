When(/^I (.*?)like the photo$/) do |like|
  find(".btn-like").click
end

Then(/^I should see the text "(.*?)" on the like button$/) do |text|
  find(".btn-like").find("span").should have_content text
end

When(/^I (.*?)comment the photo with comment "(.*?)"$/) do |comment, text|
  find(".btn-comment").click
  find(".newComment").set(text)
  find(".newComment").native.send_keys(:return)
end

Then(/^I should see the comment with the text "(.*?)"$/) do |text|
  find(".commentText").should have_content text
end

When(/^I delete the comment$/) do
	page.execute_script('$(".comment.own .icons").css("display", "block")')
  find(".delete").click
end

When(/^I edit the comment with "(.*?)"$/) do |text|
  page.execute_script('$(".comment.own .icons").css("display", "block")')
  find(".startEdit").click
  find(".edit textarea").set(text)
  find(".edit textarea").native.send_keys(:return)
end

Then(/^I shouldn't find any comment$/) do
	find(".comments").should have_content ""
end






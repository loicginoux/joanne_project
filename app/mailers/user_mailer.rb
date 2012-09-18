require 'rest_client'

class UserMailer < ActionMailer::Base

  def reset_password_email(user)
    reset_url = edit_password_reset_url(user.perishable_token)
    RestClient.post MAILGUN[:api_url]+"/messages", 
      :from => MAILGUN[:admin_mailbox],
      :to => user.email,
      :subject => "[FoodRubix] Password Reset",
      :html => "<p>A request to reset your password has been made.</p>\
              	<p>If you did not make this request, simply ignore this email.</p>\
              	<p>If you did make this request just click the link below:  </p>\
              	<p>#{reset_url}</p>\
              	<p>If the above URL does not work try copying and pasting it into your browser.  </p>\
              	<p>If you continue to have problem please feel free to contact us.</p>"
  end

  def verify_account_email(user)
    verification_url = user_verification_url(user.perishable_token)
    Rails.logger.debug ">>>>>>>>>>>>> verify account"
    RestClient.post MAILGUN[:api_url]+"/messages", 
      :from => MAILGUN[:admin_mailbox],
      :to => user.email,
      :subject => "[FoodRubix] Verify your account",
      :html => "<p>Thank you for signing up for this site. Please click the following link to verify your email address:</p>
    	          <p>#{verification_url}</p>
    	          <p>If the above URL does not work, try copying and pasting it into your browser. If you continue to have problems, please feel free to contact us.</p>"
  end

  def added_comment_email(dataPoint, comment)
    RestClient.post MAILGUN[:api_url]+"/messages", 
      :from => MAILGUN[:admin_mailbox],
      :to =>dataPoint.user.email,
      :subject => "[FoodRubix] New comment on your meal",
      :html => "<p>Hi #{dataPoint.user.username},</p>\
                <p>#{comment.user.username} has commented on one of your meals. How exciting!</p>\
                <p>View it <a href='http://www.foodrubix.com/data_points/#{dataPoint.id}'>here</a></p>"

  end
  
  def added_like_email(dataPoint, like)
    RestClient.post MAILGUN[:api_url]+"/messages", 
      :from => MAILGUN[:admin_mailbox],
      :to => dataPoint.user.email,
      :subject => "[FoodRubix] #{like.user.username} liked your meal",
      :html => "<p>Hi #{dataPoint.user.username},</p>
                <p>#{like.user.username} liked your meal. Nice one!</p>
                <p>View it <a href='http://www.foodrubix.com/data_points/#{dataPoint.id}'>here</a></p>"
  end
end

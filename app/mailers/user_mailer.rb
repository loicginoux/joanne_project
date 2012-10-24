require 'rest_client'

class UserMailer < ActionMailer::Base

  def reset_password_email(user)
    @user = user
    @reset_url = edit_password_reset_url(user.perishable_token)
    html = render :partial => "email/reset_password", :layout => "email"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => user.email,
      :subject => "[FoodRubix] Password Reset",
      :html => html.to_str
  end

  def verify_account_email(user)
    @user = user
    @verification_url = user_verification_url(user.perishable_token)
    html = render :partial => "email/verify_account", :layout => "email"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => user.email,
      :subject => "[FoodRubix] Verify your account",
      :html => html.to_str
  end

  def added_comment_email(dataPoint, comment)
    @dataPoint = dataPoint
    @comment = comment
    html = render :partial => "email/added_comment", :layout => "email"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to =>dataPoint.user.email,
      :subject => "[FoodRubix] New comment on your meal",
      :html => html.to_str

  end

  def added_like_email(dataPoint, like)
    @dataPoint = dataPoint
    @like = like
    html = render :partial => "email/added_like", :layout => "email"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => dataPoint.user.email,
      :subject => "[FoodRubix] #{like.user.username} liked your meal",
      :html => html.to_str
  end

  def new_follower_email(followee, follower)
    # html = EmailController.new.new_follower.to_str
    @followee = followee
    @follower = follower
    html = render :partial => "email/new_follower", :layout => "email"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => followee.email,
      :subject => "[FoodRubix] #{follower.username} is now following you",
      :html => html.to_str

  end
end

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

  def weekly_recap_email(users)
    users.each {|user|
      startDate = (Time.now - 7.days).utc
      endDate = Time.now.utc
      @groups = DataPoint.where(
        :user_id => user.id,
        :uploaded_at => startDate..endDate
      )
      .order("uploaded_at ASC")
      .group_by{|v| v.uploaded_at.strftime("%a %d %b %Y")}

      @user = user
      if @groups.empty?
        html = render :partial => "email/empty_recap", :layout => "email"
      else
        html = render :partial => "email/weekly_recap", :layout => "email"
      end

      RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => user.email,
      :subject => "[FoodRubix] This is what you ate this week",
      :html => html.to_str
    }
  end

  def daily_recap_email(users)
    users.each {|user|
      startDate = (Time.now - 1.days).utc
      endDate = Time.now.utc
      @data_points = DataPoint.where(
        :user_id => user.id,
        :uploaded_at => startDate..endDate
        )
      .order("uploaded_at ASC")

      @user = user

      if @data_points.empty?
        html = render :partial => "email/empty_recap", :layout => "email"
      else
        html = render :partial => "email/daily_recap", :layout => "email"
      end

      RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => user.email,
      :subject => "[FoodRubix] This is what you ate yesterday",
      :html => html.to_str

    }
  end

end

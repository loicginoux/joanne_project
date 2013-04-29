require 'rest_client'

# all arguments passed must be ids in order to be processed by a background worker
# see issue
# http://stackoverflow.com/questions/4337879/rails-absolutely-stumped-with-delayed-job-not-receiving-arguments-anywhere
#
class UserMailer < ActionMailer::Base

  def mail_upload_no_user(email)
    # this need to be put to avoid issue
    # http://stackoverflow.com/questions/4452149/rails-3-abandon-sending-mail-within-actionmailer-action
    self.message.perform_deliveries = false
    @user = User.find_by_email(email)
    @email = email
    html = render :partial => "email/mail_upload_no_user", :layout => "email"
    puts "mail upload no user for email: #{email}"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => email,
      :subject => "[FoodRubix] Wrong email used to upload a photo",
      :html => html.to_str
  end

  def mail_upload_no_file(email)
    # this need to be put to avoid issue
    # http://stackoverflow.com/questions/4452149/rails-3-abandon-sending-mail-within-actionmailer-action
    self.message.perform_deliveries = false
    @user = User.find_by_email(email)
    @email = email
    html = render :partial => "email/mail_upload_no_file", :layout => "email"
    puts "mail upload no attachement: #{email}"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => email,
      :subject => "[FoodRubix] No attachement found",
      :html => html.to_str
  end

  def mail_upload_too_big_file(email, attachment)
    # this need to be put to avoid issue
    # http://stackoverflow.com/questions/4452149/rails-3-abandon-sending-mail-within-actionmailer-action
    self.message.perform_deliveries = false
    @user = User.find_by_email(email)
    @email = email
    @attachment = attachment
    html = render :partial => "email/mail_upload_too_big_file", :layout => "email"
    puts "file size too big: #{email}"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => email,
      :subject => "[FoodRubix] Please re-send a photo under 4 MB",
      :html => html.to_str
  end

  def reset_password_email(user_id)
    self.message.perform_deliveries = false
    @user = User.find(user_id)
    @reset_url = edit_password_reset_url(@user.perishable_token)
    html = render :partial => "email/reset_password", :layout => "email"
    puts "password reset email sent to: #{@user.email}"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => @user.email,
      :subject => "[FoodRubix] Password Reset",
      :html => html.to_str
  end

  def verify_account_email(user_id)
    self.message.perform_deliveries = false
    @user = User.find(user_id)
    @verification_url = user_verification_url(@user.perishable_token)
    html = render :partial => "email/verify_account", :layout => "email"
    puts "account verification email sent to: #{@user.email} with url #{@verification_url}"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => @user.email,
      :subject => "[FoodRubix] Verify your account",
      :html => html.to_str
  end


  # this mail is sent to the owner of a photo
  def comment_on_your_photo_email(comment_id)
    self.message.perform_deliveries = false
    @comment = Comment.find(comment_id)
    @dataPoint = DataPoint.find(@comment.data_point_id)
    @user = @dataPoint.user
    html = render :partial => "email/comment_on_your_photo", :layout => "email"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => @user.email,
      :subject => "[FoodRubix] New comment on your meal",
      :html => html.to_str

    puts "new comment on your meal. email sent to: #{@user.email}, comment_id: #{@comment.id}, data_point_id: #{@dataPoint.id}"
  end


  # this mail is sent to the previous people who commented a photo
  # to notify them there is a new comment
  def others_commented_email(comment_id)
    self.message.perform_deliveries = false

    @comment = Comment.find(comment_id)
    @dataPoint = DataPoint.find(@comment.data_point_id)

    # we notify the previous commenters
    # compact remove the nil elements
    previousCommenters = @dataPoint.comments.map { |com|
      com.user unless (com.user.is(@comment.user) || com.user.is(@dataPoint.user))
    }.compact.uniq
    if previousCommenters.length > 0
      # [*users] converts one object into an array to run each against one element only
      [*previousCommenters].each {|user|
        @user = user
        html = render :partial => "email/others_commented", :layout => "email"
        RestClient.post MAILGUN[:api_url]+"/messages",
          :from => MAILGUN[:admin_mailbox],
          :to => @user.email,
          :subject => "[FoodRubix] New comment on a meal you commented",
          :html => html.to_str
        puts "comment for previous commenters. email sent to: #{@user.email}, comment_id: #{@comment.id}, data_point_id: #{@dataPoint.id}"
      }
    end
  end

  def added_like_email(data_point_id, like_id)
    self.message.perform_deliveries = false
    @dataPoint = DataPoint.find(data_point_id)
    @like = Like.find(like_id)
    @liker = @like.user
    @user = @dataPoint.user
    html = render :partial => "email/added_like", :layout => "email"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => @user.email,
      :subject => "[FoodRubix] #{@like.user.username.capitalize} liked your meal",
      :html => html.to_str
    Rails.logger.debug("new like email sent to: #{@user.email}, like_id: #{@like.id}, data_point_id: #{@dataPoint.id}")
  end



  def new_follower_email(followee_id, follower_id)
    self.message.perform_deliveries = false
    @followee = User.find(followee_id)
    @follower = User.find(follower_id)
    @user = @followee
    html = render :partial => "email/new_follower", :layout => "email"
    RestClient.post MAILGUN[:api_url]+"/messages",
      :from => MAILGUN[:admin_mailbox],
      :to => @followee.email,
      :subject => "[FoodRubix] #{@follower.username.capitalize} is now following you",
      :html => html.to_str
    puts "new follower email sent to: #{@followee.email}, follower_id: #{@follower.id}"
  end
  # handle_asynchronously :new_follower_email

  def weekly_recap_email()
    self.message.perform_deliveries = false
    users = User.includes(:preference).confirmed().active().where("preferences.weekly_email" => true)
    @leaderboard_users = User.monthly_leaderboard().limit(20)
    users.each {|user|
      Time.zone = user.timezone
      if Time.zone.now.monday? && Time.zone.now.hour == 7
        # startDate = (Time.zone.now - 7.days).utc
        # endDate = Time.zone.now.utc
        endDate = DateTime.parse((Date.today).to_s)
        startDate = DateTime.parse((endDate - 7.days).to_s)

        @slackerboard_users = user.slackerboard().limit(20)

        @groups = DataPoint.where(
          :user_id => user.id,
          :uploaded_at => startDate..endDate
        )
        .order("uploaded_at ASC")
        .group_by{|v| v.uploaded_at.strftime("%a %b %d, %Y")}

        @user = user
        puts "sending weekly email to #{user.username} at curent time #{Time.zone.now} which is in UTC #{Time.zone.now.utc}"
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
      end
    }
  end
  # handle_asynchronously :weekly_recap_email

  def daily_recap_email()
    self.message.perform_deliveries = false
    users = User.includes(:preference).confirmed().active().where("preferences.daily_email" => true)
    @leaderboard_users = User.monthly_leaderboard().limit(20)
    users.each {|user|

      Time.zone = user.timezone
      if Time.zone.now.hour == 7
        # this removes the offset that can't be done with the Date object
        endDate = DateTime.parse(Date.today.to_s)
        startDate = DateTime.parse((endDate - 1.days).to_s)

        @slackerboard_users = user.slackerboard().limit(20)

        @data_points = DataPoint.where(
          :user_id => user.id,
          :uploaded_at => startDate..endDate
          )
        .order("uploaded_at ASC")

        @user = user

        @hot_photo = DataPoint.hot_photo_awarded().order("uploaded_at").last

        @smart_choice_photo = DataPoint.smart_choice_awarded().order("uploaded_at").last


        @totalDayCalories = @data_points.map(&:calories).inject(:+) || 0

        puts "sending daily email to #{user.username} at curent time #{Time.zone.now} which is in UTC #{Time.zone.now.utc}"
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
      end
    }
  end
  # handle_asynchronously :daily_recap_email




end
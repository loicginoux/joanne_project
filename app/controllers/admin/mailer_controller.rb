class Admin::MailerController < ApplicationController

  def index
    render :partial => "email/index" , :layout => "email"

  end

  def preview_comment_your_photo()
    @dataPoint = DataPoint.last
    @comment = Comment.last
    @user = current_user
    render :partial => "email/comment_on_your_photo", :layout => "email"
  end

  def preview_others_comment()
    @dataPoint = DataPoint.last
    @comment = Comment.last
    @user = current_user
    render :partial => "email/others_commented", :layout => "email"
  end

  def preview_like()
    @dataPoint = DataPoint.last
    @like = Like.last
    @user = current_user
    render :partial => "email/added_like", :layout => "email"
  end

  def preview_follower()
    @followee = current_user
    @follower = User.last
    @user = current_user

    render :partial => "email/new_follower", :layout => "email"
  end

  def preview_verify_account()
    @user = current_user
    @verification_url = user_verification_url(@user.perishable_token)
    render :partial => "email/verify_account", :layout => "email"

  end

  def preview_reset_password()
    @user = current_user
    @reset_url = edit_password_reset_url(@user.perishable_token)
    render :partial => "email/reset_password", :layout => "email"
  end
  def preview_empty()
    @user = current_user
    startDate = (Time.zone.now - 1.days).utc
    endDate = Time.zone.now.utc
    @data_points = DataPoint.where(
      :user_id => @user.id,
      :uploaded_at => startDate..endDate
      )
    .order("uploaded_at ASC")

    render :partial => "email/empty_recap", :layout => "email"

  end

  def preview_daily()
    @user = current_user
    endDate = Date.today.to_time_in_current_zone
    startDate = endDate - 1.days
    @data_points = DataPoint.where(
      :user_id => @user.id,
      :uploaded_at => startDate..endDate
      )
    .order("uploaded_at ASC")
    @leaderboard_users = User.confirmed()
      .active()
      .order("leaderboard_points desc")
      .limit(5)

    @slackerboard_users = User.who_did_not_upload_in_last_24_hours().limit(10)

    @totalDayCalories = @data_points.map(&:calories).inject(:+) || 0

    render :partial => "email/daily_recap", :layout => "email"

  end

  def preview_weekly()
    @user = current_user
    startDate = (Time.zone.now - 7.days).utc
    endDate = Time.zone.now.utc
    @groups = DataPoint.where(
      :user_id => @user.id,
      :uploaded_at => startDate..endDate
      )
    .order("uploaded_at ASC")
    .group_by{|v| v.uploaded_at.strftime("%a %b %d, %Y")}

    render :partial => "email/weekly_recap", :layout => "email"
  end
end
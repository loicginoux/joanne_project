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
    # this removes the offset that can't be done with the Date object
    endDate = DateTime.parse(Date.today.to_s)
    startDate = DateTime.parse((endDate - 1.days).to_s)

    @data_points = DataPoint.where(
      :user_id => @user.id,
      :uploaded_at => startDate..endDate
      )
    .order("uploaded_at ASC")

    @leaderboard_users = User.monthly_leaderboard().limit(20)

    @slackerboard_users = current_user.slackerboard().limit(20)
    @hot_photo = DataPoint.hot_photo_awarded().order("uploaded_at").last

    @smart_choice_photo = DataPoint.smart_choice_awarded().order("uploaded_at").last

    render :partial => "email/empty_recap", :layout => "email"

  end

  def preview_daily()
    @user = current_user
    # this removes the offset that can't be done with the Date object
    endDate = DateTime.parse(Date.today.to_s)
    startDate = DateTime.parse((endDate - 1.days).to_s)

    @data_points = DataPoint.where(
      :user_id => @user.id,
      :uploaded_at => startDate..endDate
      )
    .order("uploaded_at ASC")

    @leaderboard_users = User.monthly_leaderboard().limit(20)

    @slackerboard_users = current_user.slackerboard().limit(20)

    @totalDayCalories = @data_points.map(&:calories).inject(:+) || 0

    @hot_photo = DataPoint.hot_photo_awarded().order("uploaded_at").last

    @smart_choice_photo = DataPoint.smart_choice_awarded().order("uploaded_at").last

    render :partial => "email/daily_recap", :layout => "email"

  end

  def preview_weekly()
    @leaderboard_users = User.monthly_leaderboard().limit(20)

    @slackerboard_users = current_user.slackerboard().limit(20)

    @user = current_user
    endDate = DateTime.parse((Date.today).to_s)
    startDate = DateTime.parse((endDate - 7.days).to_s)
    @groups = DataPoint.where(
      :user_id => @user.id,
      :uploaded_at => startDate..endDate
      )
    .order("uploaded_at ASC")
    .group_by{|v| v.uploaded_at.strftime("%a %b %d, %Y")}

    render :partial => "email/weekly_recap", :layout => "email"
  end
end
class Admin::MailerController < ApplicationController

  def preview_added_comment()
    @dataPoint = DataPoint.last
    @comment = Comment.last
    @user = User.find(11)
    render :partial => "email/added_comment", :layout => "email"
  end

  def preview_verify_account()
    @user = User.find(11)
    @verification_url = user_verification_url(@user.perishable_token)
    render :partial => "email/verify_account", :layout => "email"

  end

  def preview_empty()
    @user = User.find(11)
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
    @user = User.find(11)
    endDate = Date.today.to_time_in_current_zone
    startDate = endDate - 1.days
    @data_points = DataPoint.where(
      :user_id => @user.id,
      :uploaded_at => startDate..endDate
      )
    .order("uploaded_at ASC")

    @totalDayCalories = @data_points.map(&:calories).inject(:+)

    render :partial => "email/daily_recap", :layout => "email"

  end

  def preview_weekly()
    @user = User.find(11)
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
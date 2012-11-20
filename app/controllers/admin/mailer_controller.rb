class Admin::MailerController < ApplicationController

  def preview_empty()
    @user = User.find(11)
    startDate = (Time.now - 1.days).utc
    endDate = Time.now.utc
    @data_points = DataPoint.where(
      :user_id => @user.id,
      :uploaded_at => startDate..endDate
      )
    .order("uploaded_at ASC")

    render :partial => "email/empty_recap", :layout => "email"

  end

  def preview_daily()
    @user = User.find(11)
    startDate = (Time.now - 1.days).utc
    endDate = Time.now.utc
    @data_points = DataPoint.where(
      :user_id => @user.id,
      :uploaded_at => startDate..endDate
      )
    .order("uploaded_at ASC")

    render :partial => "email/daily_recap", :layout => "email"

  end

  def preview_weekly()
    @user = User.find(11)
    startDate = (Time.now - 7.days).utc
    endDate = Time.now.utc
    @groups = DataPoint.where(
      :user_id => @user.id,
      :uploaded_at => startDate..endDate
      )
    .order("uploaded_at ASC")
    .group_by{|v| v.uploaded_at.strftime("%a %b %d, %Y")}

    render :partial => "email/weekly_recap", :layout => "email"
  end
end
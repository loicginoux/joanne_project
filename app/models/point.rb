class Point < ActiveRecord::Base
	attr_accessible :user,
		:data_point,
		:comment,
		:like,
		:friendship,
		:number,
		:action,
		:attribution_date

	belongs_to :user
	belongs_to :data_point
	belongs_to :comment
	belongs_to :like
	belongs_to :friendship

	validates_presence_of :user,
		:number,
		:action,
		:attribution_date


	# points for each action
  ACTION_VALUE = {
    :comment => 3, #your comment on a photo
    :commented => 2, #someone else comment on your photo
    :like => 1, #your like on a photo
    :liked => 2, #someone else likes your photo
    :data_point => 1, #photo upload
    :follow => 1, #you follow someone
    :followed => 2, #someone follows you
    :profile_photo => 5,
    :daily_calories_limit => 5,
    :fb_sharing => 10,
    :hot_photo_award => 3,
    :smart_choice_award => 5,
    :joining_goal => 5 # fill in the joining goal field
  }

  ACTION_TYPE = {
    :comment => "comment", #your comment on a photo
    :commented => "comment_received", #someone else comment on your photo
    :like => "like", #your like on a photo
    :liked => "like_received", #someone else likes your photo
    :data_point => "photo_uploaded",
    :follow => "follow", #you follow someone
    :followed => "followed", #someone follows you
    :profile_photo => "profile_photo",
    :daily_calories_limit => "calories_limit",
    :fb_sharing => "fb_sharing",
    :hot_photo_award => "hot_photo_award",
    :smart_choice_award => "smart_choice_award",
    :joining_goal => "joining_goal" # fill in the joining goal field
  }

	scope :on_comments, where(:action => Point::ACTION_TYPE[:comment])
	scope :on_comments_received, where(:action => Point::ACTION_TYPE[:commented])
	scope :on_like, where(:action => Point::ACTION_TYPE[:like])
	scope :on_like_received, where(:action => Point::ACTION_TYPE[:liked])
	scope :on_photo_uploaded, where(:action => Point::ACTION_TYPE[:data_point])
	scope :on_follow, where(:action => Point::ACTION_TYPE[:follow])
	scope :on_follower, where(:action => Point::ACTION_TYPE[:followed])
	scope :on_profile_photo, where(:action => Point::ACTION_TYPE[:profile_photo])
	scope :on_daily_calories_limit, where(:action => Point::ACTION_TYPE[:daily_calories_limit])
	scope :on_fb_sharing, where(:action => Point::ACTION_TYPE[:fb_sharing])
	scope :on_hot_photo_award, where(:action => Point::ACTION_TYPE[:hot_photo_award])
	scope :on_smart_choice_award, where(:action => Point::ACTION_TYPE[:smart_choice_award])
	scope :on_joining_goal, where(:action => Point::ACTION_TYPE[:joining_goal])
	scope :on_start_month, where("action = ? OR action = ? OR action = ? OR action = ? OR action = ? OR action = ?",
			Point::ACTION_TYPE[:follow],
			Point::ACTION_TYPE[:followed],
			Point::ACTION_TYPE[:profile_photo],
			Point::ACTION_TYPE[:daily_calories_limit],
			Point::ACTION_TYPE[:fb_sharing],
			Point::ACTION_TYPE[:joining_goal] )

	# here we assume that the timezone conversion have already been done on the dates
	scope :for_period, lambda{ |startPeriod, endPeriod|
		if startPeriod && endPeriod
			Point.where(:attribution_date => startPeriod..endPeriod)
		else
			[]
		end
	}
	scope :for_user, lambda{ |user|
		if user
			Point.where(:user_id => user.id)
		else
			[]
		end
	}
	scope :for_current_month, lambda{ |tz_now|
		startP = tz_now.beginning_of_month
		endP = tz_now.end_of_month
		Point.for_period(startP,endP)
	}


end
class Preference < ActiveRecord::Base
  attr_accessible :user_id,
  	:joining_goal,
  	:coaching_intensity,
		:fb_sharing,
  	:daily_calories_limit,
		:daily_email,
    :weekly_email

   belongs_to :user

   validates :daily_calories_limit, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
end

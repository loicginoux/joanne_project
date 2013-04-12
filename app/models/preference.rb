class Preference < ActiveRecord::Base
  attr_accessible :user_id,
  	:joining_goal,
  	:coaching_intensity,
		:fb_sharing,
  	:daily_calories_limit,
		:daily_email,
    :weekly_email,
    :diet,
    :eating_habits

  belongs_to :user

  DIETS = ["Low carb", "Weight Watchers","Jenny Craig","Nutrisystem","Paleo","Vegetarian","Vegan","Volumetrics","Raw foods","Other","I eat everything"]

  validates :user, :presence => true
  validates :daily_calories_limit, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
end

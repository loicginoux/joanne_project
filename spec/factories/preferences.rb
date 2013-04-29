FactoryGirl.define do
  factory :preference do
    joining_goal "my goal"
    coaching_intensity "medium"
    fb_sharing false
    daily_calories_limit 1000
    daily_email false
    weekly_email false
    diet "vegetarian"
    eating_habits "I eat test food"
    user
  end
end
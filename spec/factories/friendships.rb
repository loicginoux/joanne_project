FactoryGirl.define do
  factory :friendship do
    user { FactoryGirl.create(:user) }
    followee { FactoryGirl.create(:followee) }
  end
end
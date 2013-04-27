FactoryGirl.define do
  factory :like do
    user
    data_point
    noMailTriggered true
  end
end
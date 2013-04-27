FactoryGirl.define do
  factory :comment do
    association :user
    association :data_point
    text "Lorem ipsum dolor sit amet."
  end
end
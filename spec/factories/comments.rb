FactoryGirl.define do
  factory :comment do
    user
    data_point
    text "Lorem ipsum dolor sit amet."
  end
end
FactoryGirl.define do
  factory :user do
    username "testuser"
    email "lginoux.spam@gmail.com"
    password "password"
    confirmed true
    active true
    association :preference, factory: :preference, strategy: :build
  end
end
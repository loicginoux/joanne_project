FactoryGirl.define do
	sequence(:username) {|n| "user#{n}" }
	sequence(:email) {|n| "email#{n}@mail.com" }

  factory :user,  aliases: [:followee] do
    username
    email
    password "password"
    confirmed true
    active true
    association :preference, factory: :preference, strategy: :build
    # picture File.new(Rails.root + 'spec/fixtures/images/test1.png')

    factory :inactive_user do
      active false
    end

    factory :unconfirmed_user do
      confirmed false
    end

    factory :hidden_user do
      hidden true
    end

    factory :first_friend_user do
      first_friend true
    end

    factory :user_with_data_points do
      ignore do
        data_points_count 1
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:data_point, evaluator.data_points_count, user: user)
      end
    end
  end
end
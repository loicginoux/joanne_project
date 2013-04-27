FactoryGirl.define do

  factory :user,  aliases: [:followee] do
    username {"user#{rand(10000).to_s}" }
    email {"user_#{rand(10000).to_s}@factory#{rand(10000)}.com" }
    password "password"
    password_confirmation "password"
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
FactoryGirl.define do
	factory :data_point do
		calories 100
		noObserver true
		description "Lorem ipsum dolor sit amet."
		photo File.new(Rails.root + 'spec/fixtures/images/test1.png')
		uploaded_at { DateTime.now }
		user

		before(:create) do |dp|
			user = FactoryGirl.create(:user)
		end

		factory :dp_with_comments do
			ignore do
				comments_count 3
			end

			after(:create) do |dp, evaluator|
				FactoryGirl.create_list(:comment, evaluator.comments_count, data_point: dp)
			end
		end

		factory :dp_with_likes do
			ignore do
				likes_count 3
			end

			after(:create) do |dp, evaluator|
				FactoryGirl.create_list(:like, evaluator.likes_count, data_point: dp)
			end
    end


    factory :dp_with_hot_photo_award do
    	hot_photo_award true
    end

    factory :dp_with_smart_choice_award do
    	smart_choice_award true
    end
  end
end
# Note: about describe and context
#  We use describe blocks to set the state of what
#  we are testing, and context blocks to group those
#   tests. This makes our tests more readable and
#   maintainable in the long run.
require 'spec_helper'

describe User do
	context "#fields" do
		it { should respondTo(:username) }
		it { should respondTo(:email) }
		it { should respondTo(:password) }
		it { should respondTo(:role) }
		it { should respondTo(:confirmed) }
		it { should respondTo(:active) }
		it { should respondTo(:timezone) }
		it { should respondTo(:picture) }
		it { should respondTo(:leaderboard_points) }
		it { should respondTo(:total_leaderboard_points) }
		it { should respondTo(:hidden) }
		it { should respondTo(:first_friend) }
	end

	context "#validations" do
		it { should validate_presence_of(:username) }
		it { should validate_uniqueness_of(:username) }
		it { should validate_presence_of(:email) }
		it { should validate_uniqueness_of(:email) }
		it { should validate_presence_of(:password) }
	end

	context "#associations" do
		it { should have_many( :authentications ).dependent(:destroy) }
	  it { should have_many( :friendships ).dependent(:destroy) }
	  it { should have_many( :followees ).through(:friendships) }
	  it { should have_many( :likes ).dependent(:destroy) }
	  it { should have_many( :yums ).through(:likes) }
	  it { should have_many( :data_points ).dependent(:destroy) }
	  it { should have_many( :leaderboard_prices ).dependent(:destroy) }
	  it { should have_many( :comments ).dependent(:destroy) }
	  it { should have_one( :preference).dependent(:destroy) }

	  it { should accept_nested_attributes_for(:data_points) }
	  it { should accept_nested_attributes_for(:authentications) }
	  it { should accept_nested_attributes_for(:preference) }
	end

	describe "#methods" do
		let!(:user) { FactoryGirl.create(:user) }

		it "should count the correct daily calories points" do
			user.daily_calories_limit_points.should eql User::LEADERBOARD_ACTION_VALUE[:daily_calories_limit]
		end
	end
end
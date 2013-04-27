# Note: about describe and context
#  We use describe blocks to set the state of what
#  we are testing, and context blocks to group those
#   tests. This makes our tests more readable and
#   maintainable in the long run.
require 'spec_helper'

describe User do
	context "#fields" do
		it { should respond_to(:username) }
		it { should respond_to(:email) }
		it { should respond_to(:password) }
		it { should respond_to(:role) }
		it { should respond_to(:confirmed) }
		it { should respond_to(:active) }
		it { should respond_to(:timezone) }
		it { should respond_to(:picture) }
		it { should respond_to(:leaderboard_points) }
		it { should respond_to(:total_leaderboard_points) }
		it { should respond_to(:hidden) }
		it { should respond_to(:picture) }


	end

	context "#virtual attributes" do
		it { should respond_to(:noObserver) }
	end

	context "#validations" do
		it { should validate_presence_of(:username) }
		it { should validate_uniqueness_of(:username) }
		it { should validate_presence_of(:email) }
		it { should validate_uniqueness_of(:email) }
		it { should validate_format_of(:email).with("test@test.com") }
		it { should validate_format_of(:email).not_with("test@test") }

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

	context "#scopes" do
		describe ".without_user" do
			let!(:included_user) { FactoryGirl.create(:user) }
			let!(:excluded_user) { FactoryGirl.create(:user) }

			it "exclude user pass in param" do
				User.without_user(excluded_user).should_not include(excluded_user)
			end

			it "include user not pass in param" do
				User.without_user(excluded_user).should include(included_user)
			end
		end

	end


	describe "#methods" do
		# let!(:user) { FactoryGirl.create(:user) }

		# it "should count the correct daily calories points" do
		# 	puts user.username
		# 	user.daily_calories_limit_points.should eql User::LEADERBOARD_ACTION_VALUE[:daily_calories_limit]
		# end
	end


end
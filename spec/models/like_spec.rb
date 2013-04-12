# Note: about describe and context
#  We use describe blocks to set the state of what
#  we are testing, and context blocks to group those
#   tests. This makes our tests more readable and
#   maintainable in the long run.
require 'spec_helper'

describe Like do
	let(:u1){ FactoryGirl.create(:user_with_data_points) }
	let(:u2){ FactoryGirl.create(:user) }
	let(:u3){ FactoryGirl.create(:user_with_data_points) }
	let(:dp) { u1.data_points.last }
	let(:dp2) { u3.data_points.last }
	let(:l1) { FactoryGirl.create(:like, :user => u1, :data_point => dp, :noMailTriggered=> true) }
	let(:l2) { FactoryGirl.create(:like, :user => u2, :data_point => dp, :noMailTriggered=> true) }
	let(:l3) { FactoryGirl.create(:like, :user => u3, :data_point => dp2, :noMailTriggered=> true) }

	context "#fields" do
		it { should respond_to(:created_at) }
		it { should respond_to(:updated_at) }
	end

	context "#validations" do
		it { should validate_presence_of(:user) }
		it { should validate_presence_of(:data_point) }
		it "cannot likes same photo twice" do
		  l4 = FactoryGirl.build(:like, :user => l1.user, :data_point => l1.data_point)
		  l4.valid?
		  l4.errors.full_messages.should include("cannot like twice the same photo")
		end
	end

	context "#associations" do
	  it { should belong_to( :user) }
	  it { should belong_to( :data_point) }
	end

	context "#scopes" do
		describe ".onOthersPhoto" do
		  it "includes likes where the fan is different from the photo's owner" do
		  	Like.onOthersPhoto().should include(l2)
		  end
		  it "excludes likes where the fan is the same as the photo's owner" do
		    Like.onOthersPhoto().should_not include(l1)
		  end
		end

		describe ".whereDataPointBelongsTo" do
			it "excludes likes made on others photos " do
			  Like.whereDataPointBelongsTo(u1).should_not include(l3)
			end
			it "includes likes on photo's of the user" do
			  Like.whereDataPointBelongsTo(u1).should include(l2)
		  	Like.whereDataPointBelongsTo(u1).should include(l1)
			end

		end
	end


	describe "#methods" do
		describe "onOwnPhoto?" do
		  it "returns false if fan is different from photo's owner"  do
		    l1.onOwnPhoto?.should be_true
		  end
		  it "returns false if fan is different from photo's owner" do
		    l2.onOwnPhoto?.should be_false
		  end
		end
		# TODO self.col_list
	end


end
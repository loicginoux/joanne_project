# Note: about describe and context
#  We use describe blocks to set the state of what
#  we are testing, and context blocks to group those
#   tests. This makes our tests more readable and
#   maintainable in the long run.
require 'spec_helper'

describe Comment do
	let(:u1){ FactoryGirl.create(:user_with_data_points) }
	let(:u2){ FactoryGirl.create(:user) }
	let(:u3){ FactoryGirl.create(:user_with_data_points) }
	let(:dp) { u1.data_points.last }
	let(:dp2) { u3.data_points.last }
	let(:com1) { FactoryGirl.create(:comment, :user => u1, :data_point => dp, :noMailTriggered=> true) }
	let(:com2) { FactoryGirl.create(:comment, :user => u2, :data_point => dp, :noMailTriggered=> true) }
	let(:com3) { FactoryGirl.create(:comment, :user => u3, :data_point => dp2, :noMailTriggered=> true) }

	context "#fields" do
		it { should respond_to(:text) }
		it { should respond_to(:created_at) }
		it { should respond_to(:updated_at) }


	end

	context "#virtual attributes" do
		it { should respond_to(:current_user) }
		it { should respond_to(:noMailTriggered) }
	end

	context "#validations" do
		it { should validate_presence_of(:text) }
		it { should validate_presence_of(:user) }
		it { should validate_presence_of(:data_point) }
		it "raises an error if editor is not owner" do
			com1.current_user = u2
			com1.update_attributes(:text => "new text")
  		com1.errors.full_messages.should include("You are not the owner")
		end
	end

	context "#associations" do
	  it { should belong_to( :user) }
	  it { should belong_to( :data_point) }
	end

	context "#scopes" do

		describe ".onOthersPhoto" do

		  it "includes comments where the commenter is different from the photo's owner" do
		  	Comment.onOthersPhoto().should include(com2)
		  end
		  it "excludes comments where the commenter is the same as the photo's owner" do
		    Comment.onOthersPhoto().should_not include(com1)
		  end
		end

		describe ".whereDataPointBelongsTo" do
			it "excludes comments made on others photos " do
			  Comment.whereDataPointBelongsTo(u1).should_not include(com3)
			end
			it "includes comments on photo's of the user" do
			  Comment.whereDataPointBelongsTo(u1).should include(com2)
		  	Comment.whereDataPointBelongsTo(u1).should include(com1)
			end

		end
	end


	describe "#methods" do
		describe "onOwnPhoto?" do
		  it "returns false if commenter is different from photo's owner"  do
		    com1.onOwnPhoto?.should be_true
		  end
		  it "returns false if commenter is different from photo's owner" do
		    com2.onOwnPhoto?.should be_false
		  end
		end
		# TODO self.col_list
	end


end
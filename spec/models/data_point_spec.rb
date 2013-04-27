# Note: about describe and context
#  We use describe blocks to set the state of what
#  we are testing, and context blocks to group those
#   tests. This makes our tests more readable and
#   maintainable in the long run.
require 'spec_helper'

describe DataPoint do

	let(:dp) { FactoryGirl.create(:data_point) }

	context "#fields" do
		it { should respond_to(:calories) }
		it { should respond_to(:created_at) }
		it { should respond_to(:updated_at) }
		it { should respond_to(:photo_content_type) }
		it { should respond_to(:photo_file_name) }
		it { should respond_to(:photo_file_size) }
		it { should respond_to(:photo_updated_at) }
		it { should respond_to(:uploaded_at) }
		it { should respond_to(:nb_comments) }
		it { should respond_to(:nb_likes) }
		it { should respond_to(:description) }
		it { should respond_to(:smart_choice_award) }
		it { should respond_to(:hot_photo_award) }

		it { should have_attached_file(:photo) }
	end

	context "#virtual attributes" do
		it { should respond_to(:noObserver) }
		it { should respond_to(:editor_id) }
	end

	context "#validations" do
		it { should validate_presence_of(:calories) }
		it { should validate_numericality_of(:calories) }
		it { should validate_presence_of(:user) }
		it { should validate_attachment_size(:photo).less_than(3.megabytes) }
		it { should validate_attachment_content_type(:photo).
			allowing('image/jpeg','image/jpg', 'image/png', 'image/gif', "image/tiff").
			rejecting('text/plain', 'text/xml') }

		it "raises an error if editor is not owner" do
			user2 = FactoryGirl.create(:user)
			dp.editor_id = user2.id
			dp.update_attributes(:calories => 123)
  		dp.errors.full_messages.should include("You are not the owner")
		end

	end

	context "#associations" do
	  it { should belong_to( :user) }
		it { should have_many( :comments ).dependent(:destroy) }
		it { should have_many( :likes ).dependent(:destroy) }
		it { should have_many( :fans).through(:likes) }

	end

	context "#scopes" do
		describe ".hot_photo_awarded" do
		  let(:dp_with_hp_award) { FactoryGirl.create(:dp_with_hot_photo_award) }
		  subject { DataPoint.hot_photo_awarded() }
		  it { should include(dp_with_hp_award)  }
		  it { should_not include(dp)  }
		end
		describe ".smart_choice_awarded" do
		  subject { DataPoint.smart_choice_awarded() }
		  let(:dp_with_sc_award) { FactoryGirl.create(:dp_with_smart_choice_award) }
		  it { should include(dp_with_sc_award)  }
		  it { should_not include(dp)  }
		end
		describe ".same_day_as" do
		  subject { DataPoint.same_day_as(Time.now) }
		  let(:dp_from_yesterday) { FactoryGirl.create(:data_point, :uploaded_at => Time.now - 1.day) }
		  it { should include(dp)  }
		  it { should_not include(dp_from_yesterday)  }
		end

	end


	describe "#methods" do
		describe ".isOwner(user)" do
		  let(:other_user) { FactoryGirl.create(:user) }
		  it "returns true if user is owner" do
		  	dp.isOwner(dp.user).should be_true
		  end
		  it "returns false if user is not owner" do
				dp.isOwner(other_user).should be_false
		  end
		end
		describe "listOfFans()" do

		  # let(:dp_with_likes) { FactoryGirl.create(:dp_with_likes) }
		  # subject() { dp_with_likes.listOfFans().map { |u| u.id } }

		  # it { should include(dp_with_likes.likes[0].user.id) }
		  # it { should_not include(dp.user.id) }
		end


		# TODO duplicate
		#TODO local_uploaded_time
		#TODO has_award?
		#TODO award
	end


end
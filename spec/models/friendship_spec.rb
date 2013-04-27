# Note: about describe and context
#  We use describe blocks to set the state of what
#  we are testing, and context blocks to group those
#   tests. This makes our tests more readable and
#   maintainable in the long run.
require 'spec_helper'

describe Friendship do
	context "#fields" do
		it { should respond_to(:created_at) }
		it { should respond_to(:updated_at) }
	end

	context "#virtual attributes" do
		it { should respond_to(:noMailTriggered) }
	end

	context "#validations" do
		it { should validate_presence_of(:user) }
		it { should validate_presence_of(:followee) }
	end

	context "#associations" do
	  it { should belong_to( :user) }
	  it { should belong_to( :followee) }
	  it "cannot follow same user twice" do
			user1 = FactoryGirl.create(:user, :username => "username123", :email => "email123@asdmail.com")
			user2 = FactoryGirl.create(:followee)
			fr1 = Friendship.create(:user => user1, :followee => user2, :noMailTriggered => true)
			fr2 = Friendship.new(:user => user1, :followee => user2, :noMailTriggered => true)
			fr2.valid?
			fr2.errors.full_messages.should include("cannot make friend twice")
	  end
	end


end
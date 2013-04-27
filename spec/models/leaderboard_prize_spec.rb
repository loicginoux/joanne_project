# Note: about describe and context
#  We use describe blocks to set the state of what
#  we are testing, and context blocks to group those
#   tests. This makes our tests more readable and
#   maintainable in the long run.
require 'spec_helper'

describe LeaderboardPrize do
	context "#fields" do
		it { should respond_to(:name) }
		it { should respond_to(:created_at) }
		it { should respond_to(:updated_at) }
	end

	context "#validations" do
		it { should validate_presence_of(:user) }
		it { should validate_presence_of(:name) }
	end

	context "#associations" do
	  it { should belong_to( :user)}
	end


end
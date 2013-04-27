# Note: about describe and context
#  We use describe blocks to set the state of what
#  we are testing, and context blocks to group those
#   tests. This makes our tests more readable and
#   maintainable in the long run.
require 'spec_helper'

describe Preference do
	context "#fields" do
		it { should respond_to(:joining_goal) }
		it { should respond_to(:coaching_intensity) }
		it { should respond_to(:fb_sharing) }
		it { should respond_to(:daily_calories_limit) }
		it { should respond_to(:daily_email) }
		it { should respond_to(:weekly_email) }
		it { should respond_to(:diet) }
		it { should respond_to(:eating_habits) }

	end


	context "#validations" do
		it { should validate_presence_of(:user) }
		it { should validate_numericality_of(:daily_calories_limit) }
	end

	context "#associations" do
	  it { should belong_to( :user) }
	end


end
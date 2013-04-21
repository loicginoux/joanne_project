class LeaderboardPrize < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :user_id
end

class LeaderboardPrice < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :user_id
  validates :user, :presence => true
  validates :name, :presence => true
end

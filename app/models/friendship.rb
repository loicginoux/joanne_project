class Friendship < ActiveRecord::Base

	attr_accessible :user, :followee, :noMailTriggered

	attr_accessor :noMailTriggered

	belongs_to :user
	belongs_to :followee, :class_name => 'User'

	validate :cannot_follow_same_user_twice
	validates :user, :presence => true
	validates :followee, :presence => true


	# prevent the system to have two likes for the same user on the same photo
	def cannot_follow_same_user_twice
		sameFriendships = Friendship.where(:user_id => self.user_id, :followee_id => self.followee_id)
		if sameFriendships.count >= 1
			errors.add(:base, "cannot make friend twice")
		end
	end
end

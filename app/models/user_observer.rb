class UserObserver < ActiveRecord::Observer
	observe :user
	def before_save(user)
		# we update the leaderboard points of the user
		if !user.leaderboard_points_changed? && !user.total_leaderboard_points_changed? && !user.updated_at_changed? && !user.last_request_at_changed?
			points = 0

			if user.picture_updated_at_changed? && user.picture_updated_at_was.nil?
				points += User::LEADERBOARD_ACTION_VALUE[:profile_photo]
			end

			user.addPoints(points) unless points == 0

		end
	end

	def after_destroy(user)
		# we remove the friendshop object where user was followee
		user.followers_friendship.each do |friendship|
			friendship.destroy
		end
	end

end

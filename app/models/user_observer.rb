class UserObserver < ActiveRecord::Observer
	observe :user
	def before_save(user)
		# we update the leaderboard points of the user
		new_points = user.leaderboard_points

		if user.picture_updated_at_changed? && user.picture_updated_at_was.nil?
			user.addPoints(User::LEADERBOARD_ACTION_VALUE[:profile_photo])
		end

		if user.fb_sharing_changed?
			if user.fb_sharing && !user.fb_sharing_was
				user.addPoints(User::LEADERBOARD_ACTION_VALUE[:fb_sharing])
			elsif !user.fb_sharing && user.fb_sharing_was
				user.removePoints(User::LEADERBOARD_ACTION_VALUE[:fb_sharing])
			end
		end

		if user.daily_calories_limit_changed?
			if user.daily_calories_limit > 0 && user.daily_calories_limit_was == 0
				user.addPoints(User::LEADERBOARD_ACTION_VALUE[:daily_calories_limit])
			elsif user.daily_calories_limit == 0 && user.daily_calories_limit_was > 0
				user.removePoints(User::LEADERBOARD_ACTION_VALUE[:daily_calories_limit])
			end
		end
		user.leaderboard_points = new_points unless new_points == user.leaderboard_points
	end

	def after_destroy(user)
		# we remove the friendshop object where user was followee
		user.followers_friendship.each do |friendship|
			friendship.destroy
		end
	end

end

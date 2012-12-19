class UserObserver < ActiveRecord::Observer
	observe :user
	def before_save(user)
		new_points = user.leaderboard_points

		# puts ">>>>>+++++>>>>++++>>>>"
		# puts new_points
		# puts "user.picture_updated_at_changed? #{user.picture_updated_at_changed?}"
		# puts "user.picture_updated_at #{user.picture_updated_at}"
		# puts "user.picture_updated_at_was #{user.picture_updated_at_was}"

		# puts "user.picture_file_name_changed? #{user.picture_file_name_changed?}"
		# puts "user.picture_file_name #{user.picture_file_name}"
		# puts "user.picture_file_name_was #{user.picture_file_name_was}"


		# puts "user.fb_sharing_changed?  #{user.fb_sharing_changed?}"
		# puts "user.fb_sharing #{user.fb_sharing}"
		# puts "user.fb_sharing_was #{user.fb_sharing_was}"
		# puts  "user.daily_calories_limit_changed? #{user.daily_calories_limit_changed?}"
		# puts "user.daily_calories_limit #{user.daily_calories_limit}"
		# puts "user.daily_calories_limit_was #{user.daily_calories_limit_was}"

		if user.picture_updated_at_changed? && user.picture_updated_at_was.nil?
			new_points += User::LEADERBOARD_ACTION_VALUE[:profile_photo]
		end

		if user.fb_sharing_changed?
			if user.fb_sharing && !user.fb_sharing_was
				new_points += User::LEADERBOARD_ACTION_VALUE[:fb_sharing]
			elsif !user.fb_sharing && user.fb_sharing_was
				new_points -= User::LEADERBOARD_ACTION_VALUE[:fb_sharing]
			end
		end

		if user.daily_calories_limit_changed?
			if user.daily_calories_limit > 0 && user.daily_calories_limit_was == 0
				new_points += User::LEADERBOARD_ACTION_VALUE[:daily_calories_limit]
			elsif user.daily_calories_limit == 0 && user.daily_calories_limit_was > 0
				new_points -= User::LEADERBOARD_ACTION_VALUE[:daily_calories_limit]
			end
		end

		# puts new_points
		# puts ">>>>>+++++>>>>++++>>>>"
		user.leaderboard_points = new_points unless new_points == user.leaderboard_points
	end

	def after_destroy(user)
		# we remove the friendshop object where user was followee
		user.followers_friendship.each do |friendship|
			friendship.destroy
		end
	end

end

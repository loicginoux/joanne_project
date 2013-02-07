class FriendshipObserver < ActiveRecord::Observer
	observe :friendship
	def after_create(record)
		UserMailer.new_follower_email(record.followee, record.user) unless record.noMailTriggered
		record.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:follow])
		record.followee.addPoints(User::LEADERBOARD_ACTION_VALUE[:followed])
	end

	def after_destroy(record)
		if record.user
			record.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:follow])
		end
		if record.followee
			record.followee.removePoints(User::LEADERBOARD_ACTION_VALUE[:followed])
		end
	end
end

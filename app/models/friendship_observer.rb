class FriendshipObserver < ActiveRecord::Observer
	observe :friendship
	def after_create(record)
		UserMailer.new_follower_email(record.followee, record.user)
		record.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:follow])
	end

	def after_destroy(record)
		record.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:follow])
	end
end

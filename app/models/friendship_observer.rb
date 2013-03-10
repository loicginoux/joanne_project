class FriendshipObserver < ActiveRecord::Observer
	observe :friendship
	def after_create(friendship)
		UserMailer.new_follower_email(friendship.followee_id, friendship.user_id) unless friendship.noMailTriggered
		friendship.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:follow])
		friendship.followee.addPoints(User::LEADERBOARD_ACTION_VALUE[:followed])
	end

	def after_destroy(friendship)
		if friendship.user
			friendship.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:follow])
		end
		if friendship.followee
			friendship.followee.removePoints(User::LEADERBOARD_ACTION_VALUE[:followed])
		end
	end
end

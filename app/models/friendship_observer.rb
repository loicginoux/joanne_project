class FriendshipObserver < ActiveRecord::Observer
	observe :friendship
	def after_create(record)
		UserMailer.new_follower_email(record.followee, record.user)
		new_points = record.user.leaderboard_points + User::LEADERBOARD_ACTION_VALUE[:follow]
        record.user.update_attributes(:leaderboard_points =>  new_points)
	end

	def after_destroy(record)
		new_points = record.user.leaderboard_points - User::LEADERBOARD_ACTION_VALUE[:follow]
        record.user.update_attributes(:leaderboard_points =>  new_points)
	end
end

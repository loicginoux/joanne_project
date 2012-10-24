class FriendshipObserver < ActiveRecord::Observer
	observe :friendship
	def after_save(record)
		followee = User.find(record.followee_id)
		follower = User.find(record.user_id)
		UserMailer.new_follower_email(followee, follower)
	end

end

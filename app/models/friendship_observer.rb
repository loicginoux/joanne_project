class FriendshipObserver < ActiveRecord::Observer
	observe :friendship
	def after_create(friendship)
		UserMailer.new_follower_email(friendship.followee_id, friendship.user_id) unless friendship.noMailTriggered
		Point.create!(
                        :user => friendship.user,
                        :friendship => friendship,
                        :number => Point::ACTION_VALUE[:follow],
                        :action => Point::ACTION_TYPE[:follow]  )
		Point.create!(
                        :user => friendship.followee,
                        :friendship => friendship,
                        :number => Point::ACTION_VALUE[:followed],
                        :action => Point::ACTION_TYPE[:followed]  )
	end
end

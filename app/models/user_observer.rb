class UserObserver < ActiveRecord::Observer
    observe :user
	def after_destroy(record)
		record.followers_friendship.each do |friendship|
   			friendship.destroy
		end
	end

end

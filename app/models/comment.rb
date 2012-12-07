class Comment < ActiveRecord::Base
  	belongs_to :user
  	belongs_to :data_point

	def onOwnPhoto?
		user = self.user_id
		usersDatapoint = self.data_point.user_id
		return user == usersDatapoint
	end
end

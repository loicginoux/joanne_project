class Comment < ActiveRecord::Base
	belongs_to :user
	belongs_to :data_point

	scope :onOthersPhoto, lambda{||
		# comment that is in a photo not belonging to the commenter
		Comment.joins(:data_point).where('data_points.user_id != comments.user_id')
	}

	scope :whereDataPointBelongsTo, lambda{|user|
		Comment.joins(:data_point).where('data_points.user_id = ?', user.id )
	}

	def onOwnPhoto?
		user = self.user_id
		usersDatapoint = self.data_point.user_id
		return user == usersDatapoint
	end

end

class Like < ActiveRecord::Base
	belongs_to :user
	belongs_to :data_point, :touch => true
	validate :cannot_like_same_data_point_twice

	scope :onOthersPhoto, lambda{||
		# comment that is in a photo not belonging to the commenter
		Like.joins(:data_point).where('data_points.user_id != likes.user_id')
	}

	scope :whereDataPointBelongsTo, lambda{|user|
		Like.joins(:data_point).where('data_points.user_id = ?', user.id )
	}

	def onOwnPhoto?
		user = self.user_id
		usersDatapoint = self.data_point.user_id
		return user == usersDatapoint
	end

	# prevent the system to have two likes for the same user on the same photo
	def cannot_like_same_data_point_twice
		sameLikes = Like.where(:user_id => self.user_id, :data_point_id => self.data_point_id)
    	if sameLikes.count >= 1
      		errors.add(:base, "cannot like twice the same photo")
    	end
  	end
end

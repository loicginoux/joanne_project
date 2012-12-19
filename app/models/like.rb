class Like < ActiveRecord::Base
	belongs_to :user
	belongs_to :data_point

	scope :onOthersPhoto, lambda{||
		# comment that is in a photo not belonging to the commenter
		Like.find_by_sql('SELECT "likes".*
			FROM "likes"
			INNER JOIN "data_points"
			ON "data_points"."id" = "likes"."data_point_id"
			WHERE "likes"."user_id" != "data_points"."user_id"'
			)

	}

	def onOwnPhoto?
		user = self.user_id
		usersDatapoint = self.data_point.user_id
		return user == usersDatapoint
	end
end

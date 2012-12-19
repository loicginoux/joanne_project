class Comment < ActiveRecord::Base
	belongs_to :user
	belongs_to :data_point

	scope :onOthersPhoto, lambda{||
		# comment that is in a photo not belonging to the commenter
		Comment.find_by_sql('SELECT "comments".*
			FROM "comments"
			INNER JOIN "data_points"
			ON "data_points"."id" = "comments"."data_point_id"
			WHERE "comments"."user_id" != "data_points"."user_id"'
		)

	}

	def onOwnPhoto?
		user = self.user_id
		usersDatapoint = self.data_point.user_id
		return user == usersDatapoint
	end
end

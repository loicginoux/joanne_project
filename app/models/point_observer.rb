class PointObserver< ActiveRecord::Observer
	observe :point


	def after_save(pt)
		update_points_and_positions(pt.user)
	end

	def after_destroy(pt)
		update_points_and_positions(pt.user)
	end


	def update_points_and_positions(user)
		points = user.points.map(&:number).inject(:+)
		monthly_points = user.points.for_current_month().map(&:number).inject(:+)
		pos = User.where("total_leaderboard_points >= ?", points).count()
		pos_monthly = User.where("leaderboard_points >= ?", monthly_points).count()

		user.update_attributes(
			:total_leaderboard_points => points,
			:leaderboard_points => monthly_points,
			:position_total_leaderboard => pos,
			:position_leaderboard => pos_monthly
		)
	end

end
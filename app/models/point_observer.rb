class PointObserver< ActiveRecord::Observer
	observe :point


	def after_save(pt)
		pt.user.update_points()
	end

	def after_destroy(pt)
		pt.user.update_points()
	end

end
class PointObserver< ActiveRecord::Observer
	observe :point
	def after_save(pt)
	end

	def after_destroy(pt)
	end
end
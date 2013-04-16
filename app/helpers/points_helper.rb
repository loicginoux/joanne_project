module PointHelper
	def get_points(points)
		if points.empty?
			0
		else
			points.map(&:number).inject(:+)
	end

end

class WeekDataPointsController < DataPointsController

  private

  def getGraphicPoints(data_points, startDate, endDate)
    weekNb = startDate.strftime("%U")
    calories = Rails.cache.fetch("/user/#{params[:user_id]}/data_points/week/#{weekNb}/graphicPoints") do
    	calories = []
    	arr = Array(startDate..endDate)
    	for date in arr
    		day_data_points = (!data_points.nil?) ? data_points[date.strftime("%F")] : {}
    		dayCalorie = 0
    		if !day_data_points.nil?
    			day_data_points.each do |photo|
    				dayCalorie += photo.calories
    			end
    		end
    		calories.push(dayCalorie)
    	end
  	  return calories
    end
    return calories
  end

  def getDataPoints(startDate, endDate, user_id )
    weekNb = startDate.strftime("%U")
    data_points = Rails.cache.fetch("/user/#{params[:user_id]}/data_points/week/#{weekNb}") do
      DataPoint.where(:user_id => user_id,:uploaded_at => startDate..endDate).order("uploaded_at ASC").group_by(&:group_by_criteria)
    end
    return data_points
  end
end
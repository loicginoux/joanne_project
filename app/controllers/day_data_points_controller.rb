class DayDataPointsController < DataPointsController

  def index
  	if(params.has_key?(:start_date) && params.has_key?(:end_date)) && params.has_key?(:user_id)
      # startDate = Time.zone.parse(params[:start_date])
      @startDate = DateTime.parse(params[:start_date])
      # endDate = Time.zone.parse(params[:end_date])
      @endDate = DateTime.parse(params[:end_date])


      @data_points = DataPoint
        .where(:user_id => params[:user_id],:uploaded_at => @startDate..@endDate)
        .order("uploaded_at ASC")
        .group_by(&:group_by_criteria)

      @graphicDatas = getGraphicPoints(@data_points, @startDate, @endDate)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end


  private

  def getGraphicPoints(data_points, startDate, endDate)
    calories = []

    data_points = @data_points[startDate.strftime("%F")]
    if !data_points.nil?
      calories = data_points.map(&:calories)
    end

    return calories
  end

end
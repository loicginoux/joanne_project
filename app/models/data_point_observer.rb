class DataPointObserver < ActiveRecord::Observer
  observe :data_point

  def after_create(data_point)
    # we add leaderboard points to the uploader if he has less than 3 image during the day
    nbDataPointSameDay =  data_point.user.data_points.same_day_as(data_point.uploaded_at).length
    unless nbDataPointSameDay > 3
      Point.create(
        :user => data_point.user,
        :data_point => data_point,
        :number => Point::ACTION_VALUE[:data_point],
        :action => Point::ACTION_TYPE[:data_point],
        :attribution_date => data_point.uploaded_at  )
    end
  end

  def after_update(data_point)

    points = 0
    beg_of_month = data_point.user.now().beginning_of_month()

    # if uploaded date has changed, we need to:
    #    - remove points from the previous date if there is now less than 3 photos
    #    - add point to the new date if there is less than 3 photos
    if data_point.uploaded_at_changed?
      dataPointsInPreviousDay = data_point.user.data_points.same_day_as(data_point.uploaded_at_was)
      dataPointsInCurrentDay = data_point.user.data_points.same_day_as(data_point.uploaded_at)

      if dataPointsInPreviousDay.length < 3
        wasOnCurrentMonth = (data_point.uploaded_at_was >= beg_of_month)
        Point.where(:data_point => data_point, :action => Point::ACTION_TYPE[:data_point]).destroy_all()
      end

      if dataPointsInCurrentDay.length <= 3
        Point.create(
          :user => data_point.user,
          :data_point => data_point,
          :number => Point::ACTION_VALUE[:data_point],
          :action => Point::ACTION_TYPE[:data_point],
          :attribution_date => data_point.uploaded_at  )
      end
    end


    # we award points if photo has been smart choice awarded
    if data_point.smart_choice_award_changed?
      if data_point.smart_choice_award && !data_point.smart_choice_award_was
        Point.create(
          :user => data_point.user,
          :data_point => data_point,
          :number => Point::ACTION_VALUE[:smart_choice_award],
          :action => Point::ACTION_TYPE[:smart_choice_award],
          :attribution_date => data_point.uploaded_at  )


      elsif !data_point.smart_choice_award && data_point.smart_choice_award_was
        Point.where(:data_point => data_point, :action => Point::ACTION_TYPE[:smart_choice_award]).destroy_all()
      end
    end

    # we award points if photo has been hot photo awarded
    if data_point.hot_photo_award_changed?
      if data_point.hot_photo_award && !data_point.hot_photo_award_was
        Point.create(
          :user => data_point.user,
          :data_point => data_point,
          :number => Point::ACTION_VALUE[:hot_photo_award],
          :action => Point::ACTION_TYPE[:hot_photo_award],
          :attribution_date => data_point.uploaded_at  )

      elsif !data_point.hot_photo_award && data_point.hot_photo_award_was
        Point.where(:data_point => data_point, :action => Point::ACTION_TYPE[:hot_photo_award]).destroy_all()
      end
    end



  end

end

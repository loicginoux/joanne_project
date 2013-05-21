class DataPointObserver < ActiveRecord::Observer
  observe :data_point


  def after_update(data_point)

    unless data_point.noObserver
      user = data_point.user
      beg_of_month = user.now().beginning_of_month()

      # because the uploaded_at field is kept in db in local timezone
      # and attribution date is not, we need to change back this field
      # to UTC before saving it.
      offset = user.timezone_offset()
      point_attribution_date = data_point.uploaded_at - offset.seconds
      # if uploaded date has changed, we need to:
      #    - remove points from the previous date if there is now less than 3 photos
      #    - add point to the new date if there is less than 3 photos
      if data_point.uploaded_at_changed?
        # when first creating uploaded_at_was is nil
        unless data_point.uploaded_at_was.nil?
          dataPointsInPreviousDay = user.data_points.same_day_as(data_point.uploaded_at_was)
        end
        dataPointsInCurrentDay = user.data_points.same_day_as(data_point.uploaded_at)

        if !dataPointsInPreviousDay.nil? && dataPointsInPreviousDay.length < 3
          wasOnCurrentMonth = (data_point.uploaded_at_was >= beg_of_month)
          Point.where(:data_point_id => data_point.id, :action => Point::ACTION_TYPE[:data_point]).destroy_all()
        end

        if dataPointsInCurrentDay.length <= 3
          Point.create!(
            :user => user,
            :data_point => data_point,
            :number => Point::ACTION_VALUE[:data_point],
            :action => Point::ACTION_TYPE[:data_point],
            :attribution_date => point_attribution_date  )
        end
      end


      # we award points if photo has been smart choice awarded
      if data_point.smart_choice_award_changed?
        if data_point.smart_choice_award && !data_point.smart_choice_award_was
          Point.create!(
            :user => user,
            :data_point => data_point,
            :number => Point::ACTION_VALUE[:smart_choice_award],
            :action => Point::ACTION_TYPE[:smart_choice_award],
            :attribution_date => point_attribution_date  )


        elsif !data_point.smart_choice_award && data_point.smart_choice_award_was
          Point.where(:data_point_id => data_point.id, :action => Point::ACTION_TYPE[:smart_choice_award]).destroy_all()
        end
      end

      # we award points if photo has been hot photo awarded
      if data_point.hot_photo_award_changed?
        if data_point.hot_photo_award && !data_point.hot_photo_award_was
          Point.create!(
            :user => user,
            :data_point => data_point,
            :number => Point::ACTION_VALUE[:hot_photo_award],
            :action => Point::ACTION_TYPE[:hot_photo_award],
            :attribution_date => point_attribution_date  )

        elsif !data_point.hot_photo_award && data_point.hot_photo_award_was
          Point.where(:data_point_id => data_point.id, :action => Point::ACTION_TYPE[:hot_photo_award]).destroy_all()
        end
      end
    end
  end

end

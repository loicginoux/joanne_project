class DataPointObserver < ActiveRecord::Observer
  observe :data_point

  def after_create(data_point)
    # we add leaderboard points to the uploader if he has less than 3 image during the day
    nbDataPointSameDay =  data_point.user.data_points.same_day_as(data_point.uploaded_at).length
    isOnCurrentMonth = (data_point.uploaded_at >= Date.today.beginning_of_month())
    data_point.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:data_point], isOnCurrentMonth) unless nbDataPointSameDay > 3
  end

  def after_update(data_point)

    points = 0
    beg_of_month = Date.today.beginning_of_month()
    isOnCurrentMonth = (data_point.uploaded_at >= beg_of_month)
    # if uploaded date has changed, we need to:
    #    - remove points from the previous date if there is now less than 3 photos
    #    - add point to the new date if there is less than 3 photos
    if data_point.uploaded_at_changed?
      dataPointsInPreviousDay = data_point.user.data_points.same_day_as(data_point.uploaded_at_was)
      dataPointsInCurrentDay = data_point.user.data_points.same_day_as(data_point.uploaded_at)

      if dataPointsInPreviousDay.length < 3
        wasOnCurrentMonth = (data_point.uploaded_at_was >= beg_of_month)
        data_point.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:data_point], wasOnCurrentMonth)
      end

      if dataPointsInCurrentDay.length <= 3
        data_point.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:data_point], isOnCurrentMonth )
      end
    end


    # we award points if photo has been smart choice awarded
    if data_point.smart_choice_award_changed?
      if data_point.smart_choice_award && !data_point.smart_choice_award_was
        data_point.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:smart_choice_award],isOnCurrentMonth )
        # we notify the photo owner
        # UserMailer.smart_choice_award_email(data_point)

      elsif !data_point.smart_choice_award && data_point.smart_choice_award_was
        data_point.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:smart_choice_award],isOnCurrentMonth )
      end
    end

    # we award points if photo has been hot photo awarded
    if data_point.hot_photo_award_changed?
      if data_point.hot_photo_award && !data_point.hot_photo_award_was
        data_point.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:hot_photo_award],isOnCurrentMonth )
      elsif !data_point.hot_photo_award && data_point.hot_photo_award_was
        data_point.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:hot_photo_award],isOnCurrentMonth )
      end
    end



  end

  def after_destroy(data_point)
    # we remove leaderboard points to the uploader if he has less than 3 image during the day
    unless data_point.noObserver
      nbDataPointSameDay =  data_point.user.data_points.same_day_as(data_point.uploaded_at).length
      points = 0
      points += User::LEADERBOARD_ACTION_VALUE[:data_point] unless nbDataPointSameDay > 3
      points += User::LEADERBOARD_ACTION_VALUE[:smart_choice_award] if data_point.smart_choice_award
      points += User::LEADERBOARD_ACTION_VALUE[:hot_photo_award] if data_point.hot_photo_award
      isOnCurrentMonth = (data_point.uploaded_at >= Date.today.beginning_of_month())
      data_point.user.removePoints(points, isOnCurrentMonth)
    end
  end
end

class DataPointObserver < ActiveRecord::Observer
  observe :data_point

  def after_create(data_point)
    # we add leaderboard points to the uploader if he has less than 3 image during the day
    nbDataPointSameDay =  data_point.user.data_points.same_day_as(data_point.uploaded_at).length
    data_point.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:data_point]) unless nbDataPointSameDay > 3
  end

  def after_update(data_point)
    points = 0
    # if uploaded date has changed, we need to:
    #    - remove points from the previous date if there is now less than 3 photos
    #    - add point to the new date if there is less than 3 photos
    if data_point.uploaded_at_changed?
      dataPointsInPreviousDay = data_point.user.data_points.same_day_as(data_point.uploaded_at_was)
      dataPointsInCurrentDay = data_point.user.data_points.same_day_as(data_point.uploaded_at)
      if dataPointsInPreviousDay.length < 3
        points -= User::LEADERBOARD_ACTION_VALUE[:data_point]
      end
      if dataPointsInCurrentDay.length <= 3
        points += User::LEADERBOARD_ACTION_VALUE[:data_point]
      end
    end


    # we award points if photo has been smart choice awarded
    if data_point.smart_choice_award_changed?
      if data_point.smart_choice_award && !data_point.smart_choice_award_was
        points += User::LEADERBOARD_ACTION_VALUE[:smart_choice_award]
        # we notify the photo owner
        UserMailer.smart_choice_award_email(dataPoint)

      elsif !data_point.smart_choice_award && data_point.smart_choice_award_was
        points -= User::LEADERBOARD_ACTION_VALUE[:smart_choice_award]
      end
    end

    # we award points if photo has been hot photo awarded
    if data_point.hot_photo_award_changed?
      if data_point.hot_photo_award && !data_point.hot_photo_award_was
        points += User::LEADERBOARD_ACTION_VALUE[:hot_photo_award]
      elsif !data_point.hot_photo_award && data_point.hot_photo_award_was
        points -= User::LEADERBOARD_ACTION_VALUE[:hot_photo_award]
      end
    end

    data_point.user.addPoints(points)

  end

  def after_destroy(data_point)
    # we remove leaderboard points to the uploader if he has less than 3 image during the day
    nbDataPointSameDay =  data_point.user.data_points.same_day_as(data_point.uploaded_at).length
    points = 0
    points += User::LEADERBOARD_ACTION_VALUE[:data_point] unless nbDataPointSameDay > 3
    points += User::LEADERBOARD_ACTION_VALUE[:smart_choice_award] if data_point.smart_choice_award
    points += User::LEADERBOARD_ACTION_VALUE[:hot_photo_award] if data_point.hot_photo_award

    data_point.user.removePoints(points)
  end
end

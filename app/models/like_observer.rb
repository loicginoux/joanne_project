class LikeObserver < ActiveRecord::Observer
  observe :like
  def after_create(like)

    # we update the number of likes for the datapoint
    dataPoint = DataPoint.find(like.data_point_id)
    dataPoint.update_attribute("nb_likes", dataPoint.nb_likes+1)

    # send the mail to photo owner
    if !like.onOwnPhoto?
      puts 2.minutes.from_now
      UserMailer(:run_at => 2.minutes.from_now).added_like_email(dataPoint, like)
    end

    unless like.user.is(dataPoint.user)
      isOnCurrentMonth = (like.created_at >= Date.today.beginning_of_month())
      # we add leaderboard points to the user who liked
      like.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:like], isOnCurrentMonth)
      # we add leaderboard points to the photo's owner
      like.data_point.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:liked], isOnCurrentMonth)
    end
  end

  def after_destroy(like)
    # we update the number of likes for the datapoint
    dataPoint = DataPoint.find(like.data_point_id)
    dataPoint.update_attribute("nb_likes", dataPoint.nb_likes-1)

    unless like.user.is(dataPoint.user)
      isOnCurrentMonth = (like.created_at >= Date.today.beginning_of_month())
      # we remove leaderboard points to the user who liked
      like.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:like], isOnCurrentMonth)
      # we remove leaderboard points to the photo's owner
      like.data_point.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:liked], isOnCurrentMonth)
    end
  end

end

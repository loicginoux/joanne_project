class LikeObserver < ActiveRecord::Observer
  observe :like
  def after_create(like)

    # we update the number of likes for the datapoint
    dataPoint = DataPoint.find(like.data_point_id)
    dataPoint.update_attributes(:nb_likes => dataPoint.nb_likes+1)

    # send the mail to photo owner
    if !like.onOwnPhoto?
      UserMailer.added_like_email(dataPoint, like)
    end

    unless like.user.is(dataPoint.user)
      # we add leaderboard points to the user who liked
      like.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:like])
      # we add leaderboard points to the photo's owner
      like.data_point.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:liked])
    end
  end

  def after_destroy(like)
    # we update the number of likes for the datapoint
    dataPoint = DataPoint.find(like.data_point_id)
    dataPoint.update_attributes(:nb_likes => dataPoint.nb_likes-1)

    unless like.user.is(dataPoint.user)
      # we remove leaderboard points to the user who liked
      like.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:like])
      # we remove leaderboard points to the photo's owner
      like.data_point.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:liked])
    end
  end

end

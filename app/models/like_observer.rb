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

    # we add leaderboard points to the user who liked
    new_points = like.user.leaderboard_points + User::LEADERBOARD_ACTION_VALUE[:like]
    like.user.update_attributes(:leaderboard_points => new_points) unless like.user.is(dataPoint.user)

  end

  def after_destroy(like)
    # we update the number of likes for the datapoint
    dataPoint = DataPoint.find(like.data_point_id)
    dataPoint.update_attributes(:nb_likes => dataPoint.nb_likes-1)

    # we remove leaderboard points to the user who liked
    new_points = like.user.leaderboard_points - User::LEADERBOARD_ACTION_VALUE[:like]
    like.user.update_attributes(:leaderboard_points => new_points) unless like.user.is(dataPoint.user)
  end

end

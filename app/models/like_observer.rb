class LikeObserver < ActiveRecord::Observer
  observe :like
  def after_create(like)
    # we update the number of likes for the datapoint
    dataPoint = DataPoint.find(like.data_point_id)
    dataPoint.update_attribute("nb_likes", dataPoint.nb_likes+1)

    # send the mail to photo owner
    puts "usermail like + #{like.data_point_id} #{like.id}"

    UserMailer.added_like_email(like.data_point_id, like.id) unless like.onOwnPhoto?


    unless like.user.is(dataPoint.user)
      isOnCurrentMonth = (like.created_at >= Date.today.beginning_of_month())
      # we add leaderboard points to the user who liked
      Point.create(
        :user => like.user,
        :like => like,
        :number => Point::ACTION_VALUE[:like],
        :action => Point::ACTION_TYPE[:like]  )
      # we add leaderboard points to the photo's owner
      Point.create(
        :user => like.data_point.user,
        :like => like,
        :data_point => like.data_point,
        :number => Point::ACTION_VALUE[:liked],
        :action => Point::ACTION_TYPE[:liked]  )
    end
  end

  def after_destroy(like)
    # we update the number of likes for the datapoint
    dataPoint = DataPoint.find(like.data_point_id)
    dataPoint.update_attribute("nb_likes", dataPoint.nb_likes-1)
  end

end

class CommentObserver < ActiveRecord::Observer
  observe :comment
  def after_create(comment)
    dataPoint = DataPoint.find(comment.data_point_id)

    # we notify the photo owner
    UserMailer.delay.comment_on_your_photo_email(dataPoint, comment) unless comment.onOwnPhoto?

    # we notify the previous commenters
    # compact remove the nil elements
    previousCommenters = dataPoint.comments.map { |com|
      com.user unless (com.user.is(comment.user) || com.user.is(dataPoint.user))
    }.compact.uniq
    if previousCommenters.length > 0
      UserMailer.delay.others_commented_email(dataPoint, comment, previousCommenters)
    end

    # we update the number of comments for the datapoint
    dataPoint.update_attribute("nb_comments", dataPoint.nb_comments+1)

    #previous comments from same commenter
    previousComments = comment.data_point.comments.where(:user_id => comment.user.id)

    if !comment.user.is(dataPoint.user) && previousComments.length <= 1
      isOnCurrentMonth = (comment.created_at >= Date.today.beginning_of_month())
      # we add leaderboard points to the commenter
      comment.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:comment], isOnCurrentMonth)
      # we add leaderboard points to the photo's owner
      comment.data_point.user.addPoints(User::LEADERBOARD_ACTION_VALUE[:commented], isOnCurrentMonth)
    end
  end

  def after_destroy(comment)
    dataPoint = DataPoint.find(comment.data_point_id)
    # we update the number of comments for the datapoint
    dataPoint.update_attribute("nb_comments", dataPoint.nb_comments-1)

    previousComments = comment.data_point.comments.where(:user_id => comment.user.id)

    if !comment.user.is(dataPoint.user) && previousComments.length < 1
      isOnCurrentMonth = (comment.created_at >= Date.today.beginning_of_month())
      # we remove leaderboard points to the commenter
      comment.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:comment], isOnCurrentMonth)
      # we remove leaderboard points to the photo's owner
      comment.data_point.user.removePoints(User::LEADERBOARD_ACTION_VALUE[:commented], isOnCurrentMonth)

    end
  end
end

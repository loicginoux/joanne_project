class CommentObserver < ActiveRecord::Observer
  observe :comment
  def after_create(comment)
    dataPoint = DataPoint.find(comment.data_point_id)

    # we notify the photo owner
    UserMailer.comment_on_your_photo_email(dataPoint, comment) unless comment.onOwnPhoto?

    # we notify the previous commenters
    # compact remove the nil elements
    previousCommenters = dataPoint.comments.map { |com|
      com.user unless (com.user.is(comment.user) || com.user.is(dataPoint.user))
    }.compact.uniq
    if previousCommenters.length > 0
      UserMailer.others_commented_email(dataPoint, comment, previousCommenters)
    end

    # we update the number of comments for the datapoint
    dataPoint.update_attributes(:nb_comments => dataPoint.nb_comments+1)

    # we add leaderboard points to the commenter
    new_points = comment.user.leaderboard_points + User::LEADERBOARD_ACTION_VALUE[:comment]
    comment.user.update_attributes(:leaderboard_points => new_points ) unless comment.user.is(dataPoint.user)
  end

  def after_destroy(comment)
    dataPoint = DataPoint.find(comment.data_point_id)
    # we update the number of comments for the datapoint
    dataPoint.update_attributes(:nb_comments => dataPoint.nb_comments-1)
    # we remove leaderboard points to the commenter
    new_points = comment.user.leaderboard_points - User::LEADERBOARD_ACTION_VALUE[:comment]
    comment.user.update_attributes(:leaderboard_points => new_points ) unless comment.user.is(dataPoint.user)
  end
end

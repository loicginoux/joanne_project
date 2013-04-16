class CommentObserver < ActiveRecord::Observer
  observe :comment
  def after_create(comment)
    dataPoint = DataPoint.find(comment.data_point_id)

    # we notify the photo owner
    puts "usermail.dealy comment"
    UserMailer.comment_on_your_photo_email(comment.id) unless comment.onOwnPhoto?

    # we notify the previous commenters
    UserMailer.others_commented_email(comment)


    # we update the number of comments for the datapoint
    dataPoint.update_attribute("nb_comments", dataPoint.nb_comments+1)

    #previous comments from same commenter
    previousComments = comment.data_point.comments.where(:user_id => comment.user.id)

    if !comment.user.is(dataPoint.user) && previousComments.length <= 1
      # we add leaderboard points to the commenter
      Point.create(
        :user => comment.user,
        :comment => comment,
        :number => Point::ACTION_VALUE[:comment],
        :action => Point::ACTION_TYPE[:comment]  )

      # we add leaderboard points to the photo's owner
      Point.create(
        :user => comment.data_point.user,
        :comment => comment,
        :data_point => comment.data_point,
        :number => Point::ACTION_VALUE[:commented],
        :action => Point::ACTION_TYPE[:commented])
    end
  end

  def after_destroy(comment)
    dataPoint = DataPoint.find(comment.data_point_id)
    # we update the number of comments for the datapoint
    dataPoint.update_attribute("nb_comments", dataPoint.nb_comments-1)
  end
end

class CommentObserver < ActiveRecord::Observer
  observe :comment
  def after_save(comment)
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

    dataPoint.update_attributes(:nb_comments => dataPoint.nb_comments+1)


  end

  def after_destroy(comment)
    dataPoint = DataPoint.find(comment.data_point_id)
    dataPoint.update_attributes(:nb_comments => dataPoint.nb_comments-1)
  end
end

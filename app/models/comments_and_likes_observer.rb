class CommentsAndLikesObserver < ActiveRecord::Observer
  observe :comment, :like  
  def after_save(record)
    dataPoint = DataPoint.find(record.data_point_id)
    if record.class == Comment
      dataPoint.update_attributes(:nb_comments => dataPoint.nb_comments+1)
      UserMailer.added_comment_email(dataPoint, record)
      
                            
    else
      dataPoint.update_attributes(:nb_likes => dataPoint.nb_likes+1) 
      UserMailer.added_like_email(dataPoint, record)
    end
  end
  
  def after_destroy(record)
    dataPoint = DataPoint.find(record.data_point_id)
    if record.class == Comment
      dataPoint.update_attributes(:nb_comments => dataPoint.nb_comments-1)
    else
      dataPoint.update_attributes(:nb_likes => dataPoint.nb_likes-1)      
    end
  end
end

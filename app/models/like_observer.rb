class LikeObserver < ActiveRecord::Observer
  observe :like
  def after_save(record)
    dataPoint = DataPoint.find(record.data_point_id)
    dataPoint.update_attributes(:nb_likes => dataPoint.nb_likes+1)
    if !record.onOwnPhoto?
      UserMailer.added_like_email(dataPoint, record)
    end
  end

  def after_destroy(record)
    dataPoint = DataPoint.find(record.data_point_id)
    dataPoint.update_attributes(:nb_likes => dataPoint.nb_likes-1)
  end
end

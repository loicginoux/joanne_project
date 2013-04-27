class DataPointSweeper < ActionController::Caching::Sweeper
  observe DataPoint

  def after_save(dp)
    expire_cache(dp)
  end

  def after_destroy(dp)
    expire_cache(dp)
  end

  private


  def expire_cache(dp)

    unless dp.uploaded_at.nil?
      weekNb = dp.uploaded_at.strftime("%U")
      monthNb = dp.uploaded_at.strftime("%m")
      Rails.cache.delete("/user/#{dp.user_id}/data_points/month/#{monthNb}")
      Rails.cache.delete("/user/#{dp.user_id}/data_points/month/#{monthNb}/graphicPoints")
      Rails.cache.delete("/user/#{dp.user_id}/data_points/week/#{weekNb}")
      Rails.cache.delete("/user/#{dp.user_id}/data_points/week/#{weekNb}/graphicPoints")
    end
    unless dp.uploaded_at_was.nil?
      weekNbWas = dp.uploaded_at_was.strftime("%U")
      monthNbWas = dp.uploaded_at_was.strftime("%m")
      Rails.cache.delete("/user/#{dp.user_id}/data_points/month/#{monthNbWas}") unless monthNb == monthNbWas
      Rails.cache.delete("/user/#{dp.user_id}/data_points/month/#{monthNbWas}/graphicPoints") unless monthNb == monthNbWas
      Rails.cache.delete("/user/#{dp.user_id}/data_points/week/#{weekNbWas}") unless weekNb == weekNbWas
      Rails.cache.delete("/user/#{dp.user_id}/data_points/week/#{weekNbWas}/graphicPoints") unless weekNb == weekNbWas
    end
  end
end
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
    weekNb = dp.uploaded_at.strftime("%U")
    monthNb = dp.uploaded_at.strftime("%m")
    puts " "
    puts "/user/#{dp.user_id}/data_points/month/#{monthNb}"
    puts "/user/#{dp.user_id}/data_points/week/#{weekNb}"
    puts " "
    Rails.cache.delete("/user/#{dp.user_id}/data_points/month/#{monthNb}")
    Rails.cache.delete("/user/#{dp.user_id}/data_points/month/#{monthNb}/graphicPoints")
    Rails.cache.delete("/user/#{dp.user_id}/data_points/week/#{weekNb}")
    Rails.cache.delete("/user/#{dp.user_id}/data_points/week/#{weekNb}/graphicPoints")
  end
end
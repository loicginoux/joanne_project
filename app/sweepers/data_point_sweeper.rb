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
    cacheKey = "/user/#{dp.user_id}/data_points/month/#{monthNb}"
    Rails.cache.delete(cacheKey) if Rails.cache.exist?(cacheKey)
    cacheKey = "/user/#{dp.user_id}/data_points/month/#{monthNb}/graphicPoints"
    Rails.cache.delete(cacheKey) if Rails.cache.exist?(cacheKey)
    cacheKey = "/user/#{dp.user_id}/data_points/week/#{weekNb}"
    Rails.cache.delete(cacheKey) if Rails.cache.exist?(cacheKey)
    cacheKey = "/user/#{dp.user_id}/data_points/week/#{weekNb}/graphicPoints"
    Rails.cache.delete(cacheKey) if Rails.cache.exist?(cacheKey)
  end
end
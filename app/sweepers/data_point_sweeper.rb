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
    # dp.user.increment_memcache_iterator()
  end
end
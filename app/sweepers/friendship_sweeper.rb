class FriendshipSweeper < ActionController::Caching::Sweeper
  observe Friendship

  def after_create(f)
    expire_cache(f)
  end

  def after_destroy(f)
    expire_cache(f)
  end

  private

  def expire_cache(f)
    Rails.cache.delete("/user/#{f.user_id}/friendships")
  end
end
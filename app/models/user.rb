class User < ActiveRecord::Base
  acts_as_authentic
  ROLES = %w[admin]
  
  def admin?
    self.role == 'admin'
  end
end

class User < ActiveRecord::Base
  acts_as_authentic
  #see http://www.tatvartha.com/2009/09/authlogic-after-the-initial-hype/
  disable_perishable_token_maintenance(true)
  before_validation :reset_perishable_token!, :on => :create 


  has_many :data_points, :dependent => :destroy
  accepts_nested_attributes_for :data_points
  
  
  #cancan gem
  ROLES = %w[admin]
  
  def admin?
    self.role == 'admin'
  end
  
  def deliver_confirm_email_instructions!
    reset_perishable_token!
    UserMailer.verify_account_email(self).deliver
  end

  def verify!
      self.confirmed = true
      self.save
  end
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.reset_password_email(self).deliver
  end
  
  def to_param
    "#{username}"
  end
  
  def isUserAllowed(user)
    if user
       user.username == self.username
    else
      false
    end
  end
end

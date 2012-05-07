class User < ActiveRecord::Base
  acts_as_authentic
  #see http://www.tatvartha.com/2009/09/authlogic-after-the-initial-hype/
  disable_perishable_token_maintenance(true)
  before_validation :reset_perishable_token!, :on => :create 
  #cancan gem
  ROLES = %w[admin]
  
  def admin?
    self.role == 'admin'
  end
  
  def deliver_confirm_email_instructions!
    reset_perishable_token!
    Notifier.deliver_confirm_email_instructions(self)
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.reset_password_email(self).deliver
  end
end

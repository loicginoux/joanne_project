class User < ActiveRecord::Base
  validates :username, 
    :presence => true,
    :uniqueness => true
  validates :email, 
    :format => { :with => /^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/ },
    :presence => true
  validates :password,
    :confirmation => true,
    :length => { :minimum => 6 },
    :presence => true,
    :on => :create
    
  acts_as_authentic
  #see http://www.tatvartha.com/2009/09/authlogic-after-the-initial-hype/
  disable_perishable_token_maintenance(true)
  before_validation :reset_perishable_token!, :on => :create 

  has_many :authentications, :dependent => :destroy, :autosave => true
  
  has_many :data_points, :dependent => :destroy
  
  accepts_nested_attributes_for :data_points
  accepts_nested_attributes_for :authentications
  
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
  
  def apply_omniauth(omniauth)
    logger.debug omniauth.inspect
    self.email = omniauth['info']['email']
    # Update user info fetching from social network
    case omniauth['provider']
    when 'facebook'
      # fetch extra user info from facebook
      username = omniauth['info']['nickname'].gsub('.', '')
      self.username = username
      
    when 'twitter'
      # fetch extra user info from twitter
    end
  end

end

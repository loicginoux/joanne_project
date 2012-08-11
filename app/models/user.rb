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
  
  has_many :friendships
  has_many :friends, :through => :friendships
      
  has_many :data_points, :dependent => :destroy
  
  accepts_nested_attributes_for :data_points
  accepts_nested_attributes_for :authentications
  
  has_attached_file :picture, 
     :styles => {
       :medium => ["200x200#",:jpg]
     },
     :storage => :s3,
     :bucket => S3_CREDENTIALS[:bucket],
     :path => ":attachment/:id/:style.:extension",
     :s3_credentials => S3_CREDENTIALS,
     :default_url => '/assets/default_user.gif'
  
  scope :without_user, lambda{|user| 
    user ? {:conditions => ["users.id != ?", user.id]} : {} }
  
  scope :without_followees, lambda{|followee_ids| 
    User.where("id NOT IN (?)", followee_ids) unless followee_ids.empty?
  }
  
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

   
  def hasFacebookConnected?
     !Authentication.find_by_provider_and_user_id("facebook", self.id).nil?
  end
  
  def canPublishOnFacebook?
    self.hasFacebookConnected? && self.fb_sharing
  end
  
  def self.prepareGroups(users, groupSize)
    groups = Array.new
    userGroup = Array.new
    $i = 1;
    users.each do|user|
      if $i<groupSize 
        userGroup.push(user)
        $i +=1;
      else
        groups.push(userGroup)
        userGroup = Array.new
        $i = 1
      end
    end
    groups.push(userGroup)
    groups
  end
  
  def apply_omniauth(omniauth)
    self.email = omniauth['info']['email']
    # Update user info fetching from social network
    case omniauth['provider']
    when 'facebook'
      # fetch extra user info from facebook
      fb_username = omniauth['extra']['raw_info']['username']
      if self.username.nil?
        self.username = fb_username
      end
      self.fb_sharing = true
    when 'twitter'
      # fetch extra user info from twitter
    end
  end
  
  def fb_publish(data_point)
    fb_authent = Authentication.find_by_provider_and_user_id("facebook", self.id)
    if self.canPublishOnFacebook?
      user = FbGraph::User.new(fb_authent.username, :access_token => fb_authent.access_token)
      user = user.fetch
      user.feed!(
        :message =>  "This is what I've been eating. What have you been eating?",
        :picture => data_point.photo.url(:medium),
        :name => 'FoodRubix',
        :link => 'http://www.foodrubix.com',
        :description => "a super cool visual food journal - the easiest way to track what you're eating"
      )
    end
  end


end

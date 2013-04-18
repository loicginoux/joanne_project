class User < ActiveRecord::Base
  #########################
  # Virtual attributes
  #########################
  attr_accessor :noObserver

  #########################
  # Validators
  #########################
  validates :username,
    :presence => true,
    :uniqueness => { :case_sensitive => false }
  validates :email,
    :format => { :with => /^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/ },
    :presence => true,
    :uniqueness => true
  validates :password,
    :confirmation => true,
    :presence => true,
    :on => :create
  # validates_attachment_size :local_picture, :less_than=>3.megabyte
  validates_attachment_size :picture, :less_than=>4.megabyte
  validates_attachment_content_type :picture, :content_type=>['image/jpeg','image/jpg', 'image/png', 'image/gif']
  # validates_attachment_content_type :local_picture, :content_type=>['image/jpeg','image/jpg', 'image/png', 'image/gif']

  #########################
  # Authlogic
  #########################
  acts_as_authentic do |c|
    c.merge_validates_format_of_login_field_options(:with => /^[a-zA-Z0-9]+$/)
    c.merge_validates_length_of_password_field_options(:minimum => 6)
    c.merge_validates_length_of_password_confirmation_field_options(:minimum => 6)
    c.perishable_token_valid_for = 1.hours
  end

  #see http://www.tatvartha.com/2009/09/authlogic-after-the-initial-hype/
  disable_perishable_token_maintenance(true)
  before_validation :reset_perishable_token!, :on => :create

  #########################
  # Associations
  #########################
  has_many :authentications, :dependent => :destroy, :autosave => true

  has_many :friendships, :dependent => :destroy
  has_many :followees, :through => :friendships, :source=> :followee

  has_many :likes,  :dependent => :destroy
  has_many :yums, :through => :likes, :source => :data_point

  has_many :data_points, :dependent => :destroy
  has_many :leaderboard_prices, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :points, :dependent => :destroy
  has_one :preference, :dependent => :destroy

  accepts_nested_attributes_for :data_points
  accepts_nested_attributes_for :authentications
  accepts_nested_attributes_for :preference

  #########################
  # Paperclip attachements
  #########################
  # has_attached_file :local_picture,
  #   :styles => {
  #     :small => ["50x50#",:jpg],
  #     :medium => ["200x200#",:jpg]
  #   },
  #   :convert_options => { :all => '-auto-orient' },
  #   :default_url => '/assets/default_user_:style.gif',
  #   :url => '/assets/:class/:attachment/:id/:style.:extension',
  #   :path => ":rails_root/app/assets/images/:class/:attachment/:id/:style.:extension"


  has_attached_file :picture,
    :styles => {
      :small => ["50x50#",:jpg],
      :medium => ["200x200#",:jpg]
    },
    :convert_options => { :all => '-auto-orient' },
    :storage => :s3,
    :bucket => S3_CREDENTIALS[:bucket],
    :path => ":attachment/:id/:style.:extension",
    :s3_credentials => S3_CREDENTIALS,
    :default_url => '/assets/default_user_:style.gif',
    :url => ':s3_alias_url',
    :s3_host_alias => CLOUDFRONT_CREDENTIALS[:host],
    :s3_permissions => :public_read

  #########################
  # Scopes
  #########################
  scope :without_user, lambda{|user| user ? {:conditions => ["users.id != ?", user.id]} : {} }
  scope :without_followees, lambda{|followee_ids| User.where("id NOT IN (?)", followee_ids) unless followee_ids.empty? }
  scope :confirmed, where(:confirmed => true)
  scope :unconfirmed, where(:confirmed => false)
  scope :active, where(:active => true)
  scope :inactive, where(:active => false)
  scope :visible, where(:hidden => false)
  scope :latest_members, lambda {||
    ret = Rails.cache.fetch("latests_members") do
      User.confirmed().active().visible().includes(:preference).order("created_at desc")
    end
  }
  # with points gotten from the user table
  scope :monthly_leaderboard, confirmed().active().visible().includes([:leaderboard_prices, :preference]).order("leaderboard_points desc, username asc")
  scope :total_leaderboard, confirmed().active().visible().includes([:leaderboard_prices, :preference]).order("total_leaderboard_points desc, username asc")

  # with points gotten calculated from the points table
  scope :monthly_leaderboard_calculated, confirmed()
    .active()
    .visible()
    .includes([:leaderboard_prices, :preference])
    .joins(:points)
    .where("points.attribution_date" => (DateTime.now.beginning_of_month)..(DateTime.now.end_of_month))
    .select("users.id, users.username, sum(points.number) as pointsNumber")
    .group("users.id")
    .order("pointsNumber desc, username desc")

  scope :total_leaderboard_calculated, confirmed()
    .active()
    .visible()
    .includes([:leaderboard_prices, :preference])
    .joins(:points)
    .select("users.id, users.username, sum(points.number) as pointsNumber")
    .group("users.id")
    .order("pointsNumber desc, username desc")


  #########################
  # Callbacks
  #########################
  # after_save :queue_upload_to_s3


  #########################
  # Methods
  #########################

  # leaderboard points for each action
  LEADERBOARD_ACTION_VALUE = {
    :comment => 3, #your comment on a photo
    :commented => 2, #someone else comment on your photo
    :like => 1, #your like on a photo
    :liked => 2, #someone else likes your photo
    :data_point => 1,
    :follow => 1, #you follow someone
    :followed => 2, #someone follows you
    :profile_photo => 5,
    :daily_calories_limit => 5,
    :fb_sharing => 10,
    :hot_photo_award => 3,
    :smart_choice_award => 5,
    :joining_goal => 5 # fill in the joining goal field
  }

  #cancan gem
  ROLES = %w[admin]

  def admin?
    self.role == 'admin'
  end

  def deliver_confirm_email_instructions!
    reset_perishable_token!
    UserMailer.verify_account_email(self.id)
  end

  # login with either
  def self.find_by_username_or_email(login)
    User.find_by_username(login) || User.find_by_email(login)
  end


  def confirmed?
    self.confirmed
  end

  def activate!
    self.active = true
    self.save
  end

  def verify!
    # empty the cache for latest members
    Rails.cache.delete("latests_members")
    # confirm the user
    self.confirmed = true
    self.activate!
    self.save
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.reset_password_email(self.id)
  end

  def to_param
    "#{username}"
  end

  def is(user)
    if user
       user.username == self.username
    else
      false
    end
  end

  def followers_friendship
    Friendship.where(:followee_id => self.id)
  end

  def followers
    Friendship.where(:followee_id => self.id).map { |f| f.user }
  end

  def isFollowing(followee)
    followees = Rails.cache.fetch("/user/#{self.id}/friendships") do
      Friendship.where(:user_id => self.id)
    end
    followees.select { |f| f.followee_id == followee.id }
  end

  def hasFacebookConnected?
     !Authentication.find_by_provider_and_user_id("facebook", self.id).nil?
  end

  def canPublishOnFacebook?
    self.hasFacebookConnected? && self.preference.fb_sharing
  end

  def positionLeadership
    User.find_by_sql(['
      SELECT "u1".username,
            "u1".leaderboard_points,
            "u1".total_leaderboard_points,
            (SELECT count(*)
              FROM "users" as "u2"
              WHERE "u2".leaderboard_points > "u1".leaderboard_points
                AND "u2"."confirmed" = \'t\'
                AND "u2"."active" = \'t\'
            )+1 as "position",
            (SELECT count(*)
              FROM "users" as "u3"
              WHERE "u3".total_leaderboard_points > "u1".total_leaderboard_points
                AND "u3"."confirmed" = \'t\'
                AND "u3"."active" = \'t\'
            )+1 as "all_time_position"
      FROM  "users" as "u1"
      WHERE "u1".id = ?', self.id]).first
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
      puts "image"
      puts omniauth[:info][:image]
      if omniauth[:info][:image]
        self.picture = open(omniauth[:info][:image])
        puts "self.picture"
        puts self.picture
      end
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
        :picture => data_point.pic().url(:medium),
        :name => 'FoodRubix',
        :link => 'http://www.foodrubix.com',
        :description => "a super cool visual food journal - the easiest way to track what you're eating"
      )
    end
  end

  def like(data_point)
    return data_point.likes.where(:user_id => self.id).first
  end

  def getEmailProviderUrl()
    lookup = {
      "gmail"=> "http://www.gmail.com",
      "hotmail"=> "http://www.hotmail.com",
      "outlook"=> "http://www.outlook.com",
      "yahoo"=> "http://www.yahoo.com",
      "icloud"=> "http://www.icloud.com",
      "aol"=> "http://www.mail.aim.com"
    }
    match = self.email.match /@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*)\./
    provider = match[1]
    return lookup[provider]
  end

  def now()
    Time.zone = self.timezone
    now = Time.zone.now
    Time.zone = Rails.application.config.time_zone
    return now
  end

  def timezone_offset()
    Time.zone = self.timezone
    offset = Time.zone.now.utc_offset
    Time.zone = Rails.application.config.time_zone
    return offset
  end

  # returns all users that haven't uploaded anything in the last 24 hours
  # this is not in scope because the "last 24 hours" depends on the user who request it and his timezone
  def slackerboard()
    offset = self.timezone_offset()
    users_who_uploaded_yesterday = User.joins(:data_points).select("distinct users.*").where("data_points.uploaded_at >= ?", (Time.now  + (offset).seconds).beginning_of_day - 1.day)
    if users_who_uploaded_yesterday.length == 0
      User.active().confirmed().visible().includes(:preference).order("username desc")
    else
      User.active().confirmed().visible().includes(:preference).order("username desc").where("id NOT IN ("+users_who_uploaded_yesterday.map(&:id).join(",")+")")
    end
  end


  def pic()
    # (self.picture?) ? self.picture : self.local_picture
    self.picture
  end


end

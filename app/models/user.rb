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
  validates_attachment_size :local_picture, :less_than=>3.megabyte
  validates_attachment_size :picture, :less_than=>3.megabyte
  validates_attachment_content_type :picture, :content_type=>['image/jpeg','image/jpg', 'image/png', 'image/gif']
  validates_attachment_content_type :local_picture, :content_type=>['image/jpeg','image/jpg', 'image/png', 'image/gif']

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
  has_one :preference, :dependent => :destroy

  accepts_nested_attributes_for :data_points
  accepts_nested_attributes_for :authentications
  accepts_nested_attributes_for :preference

  #########################
  # Paperclip attachements
  #########################
  has_attached_file :local_picture,
    :styles => {
      :small => ["50x50#",:jpg],
      :medium => ["200x200#",:jpg]
    },
    :convert_options => { :all => '-auto-orient' },
    :default_url => '/assets/default_user_:style.gif',
    :url => '/assets/:class/:attachment/:id/:style.:extension',
    :path => ":rails_root/app/assets/images/:class/:attachment/:id/:style.:extension"


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
    ret = Rails.cache.read("latests_members")
    if ret.nil?
      ret = User.confirmed().active().visible().includes(:preference).order("created_at desc")
      Rails.cache.write("latests_members", ret)
    end
    return ret
  }
  scope :monthly_leaderboard, confirmed().active().visible().includes([:leaderboard_prices, :preference]).order("leaderboard_points desc, username asc")
  scope :total_leaderboard, confirmed().active().visible().includes([:leaderboard_prices, :preference]).order("total_leaderboard_points desc, username asc")



  #########################
  # Callbacks
  #########################
  after_save :queue_upload_to_s3


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
    :smart_choice_award => 5
  }

  #cancan gem
  ROLES = %w[admin]

  def admin?
    self.role == 'admin'
  end

  def deliver_confirm_email_instructions!
    reset_perishable_token!
    UserMailer.delay.verify_account_email(self)
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
    UserMailer.delay.reset_password_email(self)
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
    followees = Rails.cache.read("/user/#{self.id}/friendships")
    if followees.nil?
      followees =  Friendship.where(:user_id => self.id)
      Rails.cache.write("/user/#{self.id}/friendships", followees)
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

  def assign_leaderboard_points(monthly = false)
    points = 0
    points += comments_points(monthly)
    points += commented_points(monthly)
    points += likes_points(monthly)
    points += liked_points(monthly)
    points += photo_upload_points(monthly)
    points += followee_points()
    points += follower_points()
    points += profile_photo_points()
    points += daily_calories_limit_points()
    points += fb_sharing_points()
    points += smart_choice_award_points(monthly)
    points += hot_photo_award_points(monthly)
    return points
  end



  def comments_points(monthly = false)
    myComments = self.comments

    if monthly
      myComments = myComments.where(:created_at => Date.today.beginning_of_month..Date.today.end_of_month)
    end
    myComments.group(Comment.col_list).length * User::LEADERBOARD_ACTION_VALUE[:comment]
  end

  def commented_points(monthly = false)
    comments = Comment.onOthersPhoto().whereDataPointBelongsTo(self)
    if monthly
      comments = comments.where(:created_at => Date.today.beginning_of_month..Date.today.end_of_month)
    end
    comments.group(Comment.col_list).length * User::LEADERBOARD_ACTION_VALUE[:commented]
  end

  def likes_points(monthly = false)
    likes = self.likes.onOthersPhoto()
    if monthly
      likes = likes.where(:created_at => Date.today.beginning_of_month..Date.today.end_of_month)
    end
    likes.length * User::LEADERBOARD_ACTION_VALUE[:like]
  end

  def liked_points(monthly = false)
    likes = Like.onOthersPhoto().whereDataPointBelongsTo(self)
    if monthly
      likes = likes.where(:created_at => Date.today.beginning_of_month..Date.today.end_of_month)
    end
    likes.length * User::LEADERBOARD_ACTION_VALUE[:liked]
  end

  def followee_points()
    self.followees.length * User::LEADERBOARD_ACTION_VALUE[:follow]
  end

  def follower_points()
    self.followers.length * User::LEADERBOARD_ACTION_VALUE[:followed]
  end

  def profile_photo_points()
    (self.picture.nil?) ? 0 : User::LEADERBOARD_ACTION_VALUE[:profile_photo]
  end

  def daily_calories_limit_points()
    (self.preference.daily_calories_limit == 0) ? 0 : User::LEADERBOARD_ACTION_VALUE[:daily_calories_limit]
  end

  def fb_sharing_points()
    (self.preference.fb_sharing) ? User::LEADERBOARD_ACTION_VALUE[:fb_sharing] : 0
  end

  def smart_choice_award_points(monthly = false)
    dp = self.data_points.smart_choice_awarded()
    if monthly
      dp = dp.where(:uploaded_at => Date.today.beginning_of_month..Date.today.end_of_month)
    end
    dp.length * User::LEADERBOARD_ACTION_VALUE[:smart_choice_award]
  end

  def hot_photo_award_points(monthly = false)
    dp = self.data_points.hot_photo_awarded()
    if monthly
      dp = dp.where(:uploaded_at => Date.today.beginning_of_month..Date.today.end_of_month)
    end
    dp.length * User::LEADERBOARD_ACTION_VALUE[:hot_photo_award]
  end

  def photo_upload_points(monthly = false)
    # a point is awarded per photo and per day with a limit of 3 photo/point a day.
    # we group a user photo per day,
    # then we calculate the number of photo per day
    # and for each day we add the points per photo. If a day has more than 3 photos, we count it as 3 points
    dp = self.data_points
    if monthly
      dp = dp.where(:uploaded_at => Date.today.beginning_of_month..Date.today.end_of_month)
    end
    dp.group_by(&:group_by_criteria).map {|k,v| v.length}.inject(0){|sum, i| (i<4) ? sum+i*User::LEADERBOARD_ACTION_VALUE[:data_point] : sum+3}
  end

  def addPoints(points, onMonthlyLeaderboard = true)
    unless points == 0
      # we remove points on current month only if onMonthlyLeaderboard
      new_points = (onMonthlyLeaderboard) ? self.leaderboard_points + points : self.leaderboard_points

      new_total_points = self.total_leaderboard_points + points
      puts "#{points} points added to #{self.username}, pass from #{self.leaderboard_points} to #{new_points} points (total: from #{self.total_leaderboard_points} to #{new_total_points})"
      self.update_attributes({
        :leaderboard_points =>  new_points,
        :total_leaderboard_points => new_total_points
      })
    end
  end

  def removePoints(points, onMonthlyLeaderboard = true)
    self.addPoints(-points, onMonthlyLeaderboard)
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


  def queue_upload_to_s3()
    if self.local_picture_updated_at_changed? && !self.local_picture_updated_at.nil?
      self.delay.upload_to_s3
      self.delay({:run_at => 3.minutes.from_now}).delete_local_picture
    end
  end

  def upload_to_s3
    self.picture = self.local_picture
    self.save
  end

  def delete_local_picture
    if !self.picture_updated_at.nil?
      User.skip_callback(:save)
      self.local_picture = nil
      self.save
      User.set_callback(:save)
   end
  end

  def pic()
    (self.picture?) ? self.picture : self.local_picture
  end

  # # see http://quickleft.com/blog/faking-regex-based-cache-keys-in-rails
  # # this iterator allow to fake Regex-Based Cache Keys in Rails
  # # we increment to flush the cash for this user
  # def increment_memcache_iterator()
  #   Rails.cache.write("user-#{self.id}-memcache-iterator", self.memcache_iterator() + 1)
  # end

  # def memcache_iterator()
  #   # fetch the user's memcache key
  #   # If there isn't one yet, assign it a random integer between 0 and 10
  #   Rails.cache.fetch("/user/#{self.id}/memcache-iterator") do
  #      return "1"
  #   end
  # end

  # def iterative_cache_key()
  #   "/user/#{self.id}/memcache-iterator/#{self.memcache_iterator()}"
  # end
end

class User < ActiveRecord::Base
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
  validates_attachment_size :picture, :less_than=>3.megabyte
  validates_attachment_content_type :picture, :content_type=>['image/jpeg','image/jpg', 'image/png', 'image/gif']

  acts_as_authentic do |c|
    c.merge_validates_format_of_login_field_options(:with => /^[a-zA-Z0-9]+$/)
    c.merge_validates_length_of_password_field_options(:minimum => 6)
    c.merge_validates_length_of_password_confirmation_field_options(:minimum => 6)
    c.perishable_token_valid_for = 1.hours
  end

  #see http://www.tatvartha.com/2009/09/authlogic-after-the-initial-hype/
  disable_perishable_token_maintenance(true)
  before_validation :reset_perishable_token!, :on => :create

  has_many :authentications, :dependent => :destroy, :autosave => true

  has_many :friendships, :dependent => :destroy
  has_many :followees, :through => :friendships, :source=> :followee

  has_many :likes,  :dependent => :destroy
  has_many :yums, :through => :likes, :source => :data_point

  has_many :data_points, :dependent => :destroy
  has_many :comments, :dependent => :destroy

  accepts_nested_attributes_for :data_points
  accepts_nested_attributes_for :authentications

  has_attached_file :picture,
     :styles => {
       :small => ["50x50#",:jpg],
       :medium => ["200x200#",:jpg]
     },
     :storage => :s3,
     :bucket => S3_CREDENTIALS[:bucket],
     :path => ":attachment/:id/:style.:extension",
     :s3_credentials => S3_CREDENTIALS,
     :default_url => '/assets/default_user.gif'


  scope :without_user, lambda{|user| user ? {:conditions => ["users.id != ?", user.id]} : {} }
  scope :without_followees, lambda{|followee_ids| User.where("id NOT IN (?)", followee_ids) unless followee_ids.empty? }
  scope :confirmed, where(:confirmed => true)
  scope :unconfirmed, where(:confirmed => false)
  scope :active, where(:active => true)
  scope :inactive, where(:active => false)
  scope :latest_members, confirmed().active().order("created_at desc").where("username != 'joanne'").where("username != 'loknackie'")
  scope :monthly_leaderboard, confirmed().active().where("username != 'joanne'").where("username != 'loknackie'").order("leaderboard_points desc")
  scope :total_leaderboard, confirmed().active().where("username != 'joanne'").where("username != 'loknackie'").order("total_leaderboard_points desc")
  scope :who_uploaded_in_last_24_hours, joins(:data_points).select("distinct users.*").where("data_points.uploaded_at >= ?", 1.day.ago)
  scope :slackerboard, lambda { ||
    # users who didn;t upload anything in last 24 hours
    users = User.who_uploaded_in_last_24_hours
    if users.empty?
      User.active().confirmed().where("username != 'joanne'").where("username != 'loknackie'").order("username desc")
    else
      User.active().confirmed().where("username != 'joanne'").where("username != 'loknackie'").order("username desc").where("id NOT IN ("+User.who_uploaded_in_last_24_hours.map(&:id).join(",")+")")
    end
  }




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
    UserMailer.verify_account_email(self)
  end


  def confirmed?
    self.confirmed
  end

  def activate!
    self.active = true
    self.save
  end

  def verify!
    self.confirmed = true
    self.activate!
    self.save
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.reset_password_email(self)
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
    Friendship.where(:user_id => self.id, :followee_id => followee.id)
  end

  def hasFacebookConnected?
     !Authentication.find_by_provider_and_user_id("facebook", self.id).nil?
  end

  def canPublishOnFacebook?
    self.hasFacebookConnected? && self.fb_sharing
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

  def like(data_point)
    return Like.where(
      :user_id => self.id,
      :data_point_id => data_point.id
    ).first
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
    myComments.onOthersPhoto().group(Comment.col_list).length * User::LEADERBOARD_ACTION_VALUE[:comment]
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
    self.likes.onOthersPhoto().length * User::LEADERBOARD_ACTION_VALUE[:like]
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
    (self.daily_calories_limit == 0) ? 0 : User::LEADERBOARD_ACTION_VALUE[:daily_calories_limit]
  end

  def fb_sharing_points()
    (self.fb_sharing) ? User::LEADERBOARD_ACTION_VALUE[:fb_sharing] : 0
  end

  def smart_choice_award_points(monthly = false)
    dp = self.data_points.smart_choice_awarded()
    if monthly
      dp = dp.where(:created_at => Date.today.beginning_of_month..Date.today.end_of_month)
    end
    dp.length * User::LEADERBOARD_ACTION_VALUE[:smart_choice_award]
  end

  def hot_photo_award_points(monthly = false)
    dp = self.data_points.hot_photo_awarded()
    if monthly
      dp = dp.where(:created_at => Date.today.beginning_of_month..Date.today.end_of_month)
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
      dp = dp.where(:created_at => Date.today.beginning_of_month..Date.today.end_of_month)
    end
    dp.group_by(&:group_by_criteria).map {|k,v| v.length}.inject(0){|sum, i| (i<4) ? sum+i*User::LEADERBOARD_ACTION_VALUE[:data_point] : sum+3}
  end

  def addPoints(points)
    new_points = self.leaderboard_points + points
    new_total_points = self.total_leaderboard_points + points
    puts "#{points} points added to #{self.username}, pass from #{self.leaderboard_points} to #{new_points} points (total: from #{self.total_leaderboard_points} to #{new_total_points})"
    self.update_attributes({
      :leaderboard_points =>  new_points,
      :total_leaderboard_points => new_total_points
    })
  end

  def removePoints(points)
    self.addPoints(-points)
  end


end

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
  has_many :leaderboard_prizes, :dependent => :destroy
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
    :default_url => '/assets/default_user_:style.gif'
    # :convert_options => { :all => '-auto-orient' },
    # :storage => :s3,
    # :bucket => S3_CREDENTIALS[:bucket],
    # :path => ":attachment/:id/:style.:extension",
    # :s3_credentials => S3_CREDENTIALS,
    # :url => ':s3_alias_url',
    # :s3_host_alias => CLOUDFRONT_CREDENTIALS[:host],
    # :s3_permissions => :public_read

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
  scope :in_leadeboard, active().confirmed().visible()
  scope :latest_members, lambda {||
    ret = Rails.cache.fetch("latests_members") do
      User.in_leadeboard().includes(:preference).order("created_at desc")
    end
  }
  # with points gotten from the user table
  scope :monthly_leaderboard, confirmed().active().visible().includes([:leaderboard_prizes, :preference]).order("leaderboard_points desc, username asc")
  scope :total_leaderboard, confirmed().active().visible().includes([:leaderboard_prizes, :preference]).order("total_leaderboard_points desc, username asc")

  # with points gotten calculated from the points table
  scope :monthly_leaderboard_calculated, confirmed()
    .active()
    .visible()
    .includes([:leaderboard_prizes, :preference])
    .joins(:points)
    .where("points.attribution_date" => (DateTime.now.beginning_of_month)..(DateTime.now.end_of_month))
    .select("users.id, users.username, sum(points.number) as pointsNumber")
    .group("users.id")
    .order("pointsNumber desc, username desc")

  scope :total_leaderboard_calculated, confirmed()
    .active()
    .visible()
    .includes([:leaderboard_prizes, :preference])
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
      if omniauth[:info][:image]
        self.picture = open(omniauth[:info][:image])
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
        :picture => data_point.photo.url(:medium),
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


  def update_points()
    points = self.points.map(&:number).inject(:+) || 0
    monthly_points = self.points.for_current_month(self.now()).map(&:number).inject(:+) || 0
    self.update_attributes(
      :total_leaderboard_points => points,
      :leaderboard_points => monthly_points,
    )
  end

  def email_progress_bar_data(date)
    array = []
    offset = self.timezone_offset()

    if date.wday == 0
      # on sunday, start of week is the current day so we get the previous sunday
      startWeek = (date - 1.days).beginning_of_week(:sunday)
    else
      startWeek = date.beginning_of_week(:sunday)
    end
    endWeek = startWeek.end_of_week(:sunday)
    photos = DataPoint.select([:id, :created_at])
      .where(:user_id =>self.id, :created_at => startWeek..endWeek)
      .order("created_at ASC")
      .group_by{|d| (d.created_at + (offset).seconds).strftime("%w")}


    for i in 0..6
      day = startWeek + i.days
      first_letter = day.strftime("%A")[0,1]
      has_created_photo = ( !photos[i.to_s].nil?)
      array.push({
        :first_letter => first_letter,
        :has_created_photo => has_created_photo
      })
    end
    return array
  end


  # this is run every day at midnight, and check that yesterday's score
  # is not better that the user's best score
  # if it is, it replaces it
  def calculate_best_score()
    tz_start_yesterday = (self.now().beginning_of_day()) - 1.days
    tz_end_yesterday = tz_start_yesterday + 1.days

    # score for the day of yesterday
    daily_score = Point.for_user(self)
      .for_period(tz_start_yesterday,tz_end_yesterday)
      .map(&:number).inject(:+) || 0

    puts "daily score for user '#{self.username}' for #{tz_start_yesterday}: #{daily_score} - best score: #{self.best_daily_score}"
    if (self.best_daily_score < daily_score)
      self.update_attributes(:best_daily_score => daily_score)
    end
  end

  # this is run every day, and update streak attributes
  # depending on phot upload from yesterday
  def calculate_streaks()
    tz_start_yesterday = ((self.now().beginning_of_day()) - 1.days)
    tz_end_yesterday = (tz_start_yesterday + 1.days)

    nbPhotos = self.data_points.where(:created_at => tz_start_yesterday..tz_end_yesterday).count()
    new_streak = (nbPhotos > 0) ? self.streak + 1 : 0
    puts "nbPhotos for user '#{self.username}' for #{tz_start_yesterday}: #{nbPhotos} - user.streak: #{self.streak} - user.best_streak: #{self.best_streak}"
    if new_streak > self.best_streak
      self.update_attributes(:streak => new_streak, :best_streak => new_streak)
    else
      self.update_attributes(:streak => new_streak)
    end
  end


  def prepare_weekly_stats()
    stats = {
      "intro" => {
        "daily_calories_limit" => self.preference.daily_calories_limit
      },
      "week_calories" => {}
    }
    # startDate = (Time.zone.now - 7.days).utc
    # endDate = Time.zone.now.utc
    end_current_week   = DateTime.parse((Date.today).to_s)
    start_current_week = DateTime.parse((end_current_week - 7.days).to_s)
    start_1_week_ago   = DateTime.parse((end_current_week - 14.days).to_s)
    start_2_weeks_ago  = DateTime.parse((end_current_week - 21.days).to_s)
    start_3_weeks_ago  = DateTime.parse((end_current_week - 28.days).to_s)

    current_week_photos = DataPoint.for_week(self, start_current_week, end_current_week )
    last_week_photos = DataPoint.for_week(self, start_1_week_ago, start_current_week )

    stats["week_calories"]["current_week"] = current_week_photos.order("uploaded_at ASC")
      .group_by{|v| v.uploaded_at.strftime("%w")} #sorted by week day number

    stats["week_calories"]["last_week"] = last_week_photos.order("uploaded_at ASC")
      .group_by{|v| v.uploaded_at.strftime("%w")} #sorted by week day number

    stats["week_calories"]["2_weeks_ago"] = DataPoint.for_week(self, start_2_weeks_ago, start_1_week_ago )
      .map(&:calories).inject(:+) || 0

    stats["week_calories"]["3_weeks_ago"] = DataPoint.for_week(self, start_3_weeks_ago, start_2_weeks_ago )
      .map(&:calories).inject(:+) || 0


    stats["intro"]["current_week_calories"] = current_week_photos.map(&:calories).inject(:+) || 0
    stats["intro"]["last_week_calories"] = last_week_photos.map(&:calories).inject(:+) || 0

    current_week_nb_days_below_limit = 0
    last_week_nb_days_below_limit = 0

    for i in 0..6
      day_photos = stats["week_calories"]["current_week"][i.to_s]
      day_calories = (day_photos.nil?)? 0 : day_photos.map(&:calories).inject(:+)
      if self.preference.daily_calories_limit != 0 && day_calories > 0  && self.preference.daily_calories_limit >= day_calories
        current_week_nb_days_below_limit += 1
      end
      stats["week_calories"]["current_week"][i.to_s] = day_calories
    end

    for i in 0..6
      day_photos = stats["week_calories"]["last_week"][i.to_s]
      day_calories = (day_photos.nil?)? 0 : day_photos.map(&:calories).inject(:+)
      if stats["intro"]["daily_calories_limit"] && day_calories > 0 && stats["intro"]["daily_calories_limit"] >= day_calories
        last_week_nb_days_below_limit += 1
      end
      stats["week_calories"]["last_week"][i.to_s] = day_calories
    end

    stats["intro"]["current_week_nb_days_below"] = current_week_nb_days_below_limit
    stats["intro"]["last_week_nb_days_below"] = last_week_nb_days_below_limit

    puts " "
    puts ">>>>>>>>>>>>>>>>>>"
    puts "stats: "+stats.inspect
    puts ">>>>>>>>>>>>>>>>>"
    puts " "
    return stats
  end
end





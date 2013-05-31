class DataPoint < ActiveRecord::Base

  attr_accessible :user_id,
    :calories,
    :uploaded_at,
    :nb_comments,
    :nb_likes,
    :description,
    :smart_choice_award,
    :hot_photo_award,
    :photo
  #########################
  # Virtual attributes
  #########################
  # set to true to skip observers
  attr_accessor :noObserver
  # alow access to current_user in model
  attr_accessor :editor_id

  #########################
  # Validators
  #########################
  validates_presence_of :calories, :user, :photo
  validates_numericality_of :calories, :only_integer => true
  validates_attachment_size :photo, :less_than=>4.megabyte
  validates_attachment_content_type :photo, :content_type=>['image/jpeg','image/jpg', 'image/png', 'image/gif', "image/tiff"]
  validate :editor_must_be_owner, :on => :update

  def editor_must_be_owner
    if editor_id && (editor_id != user_id)
      errors[:base] << "You are not the owner"
    end
  end

  #########################
  # Paperclip attachements
  #########################

  has_attached_file :photo,
    :styles => {
      :thumbnail => ["50x50#",:jpg],
      :medium => ["220x220#",:jpg],
      :big => ["380x380#",:jpg]
    },
    :default_url => '/assets/not-available.jpg'

    # :storage => :s3,
    # :bucket => S3_CREDENTIALS[:bucket],
    # :path => ":attachment/:id/:style.:extension",
    # # :url => ':s3_alias_url',
    # # :s3_host_alias => CLOUDFRONT_CREDENTIALS[:host],
    # :s3_credentials => S3_CREDENTIALS,
    # :s3_permissions => :public_read

  #########################
  # Associations
  #########################
  belongs_to :user
  has_many :comments, :dependent => :destroy, :order => 'created_at ASC'
  has_many :likes, :dependent => :destroy
  has_many :fans, :through => :likes, :source => :user
  has_many :points, :dependent => :destroy

  #########################
  # Scopes
  #########################
  scope :hot_photo_awarded, where(:hot_photo_award => true)
  scope :smart_choice_awarded, where(:smart_choice_award => true)
  scope :same_day_as, lambda { |date|
    if date
      DataPoint.where(:uploaded_at => date.beginning_of_day..date.end_of_day)
    else
      []
    end
  }
  scope :for_week, lambda { |user, starW, endW|
    DataPoint.select([:calories, :uploaded_at]).where(
      :user_id => user.id,
      :uploaded_at => starW..endW
    )
  }


  #########################
  # Callbacks
  #########################


  #########################
  # Methods
  #########################
  #
  # if you are using attr_accessible to protect certain attributes, you will need to allow these:
  # attr_accessible :photo, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at

  # issue about encoding file
  # https://github.com/thoughtbot/paperclip/issues/301
  def image=(image)
    self.image.assign image.tempfile
  end

  def isOwner(user)
    if user
      user.id == self.user.id
    else
      false
    end
  end

  def listOfFans()
    self.fans.map{|dp| dp.username.capitalize}.to_sentence
  end

  def group_by_criteria
    if uploaded_at.nil?
      created_at.to_date.to_s(:db)
    else
      uploaded_at.to_date.to_s(:db)
    end
  end


  def pic()
    self.photo
  end

  # return the iso format and remove the "Z" from UTC timezone
  def local_uploaded_time
    self.uploaded_at.strftime("%Y-%m-%d %H:%M")
  end

  def has_award?
    return (self.hot_photo_award || self.smart_choice_award)
  end

  def award
    if self.hot_photo_award
      "Hot Photo"
    elsif self.smart_choice_award
      "Smart Choice"
    else
      ""
    end
  end

  def self.duplicate (id, newTime)
    return unless id
    source = DataPoint.find(id)
    clone = source.dup
    clone.photo = source.photo
    clone.hot_photo_award = false
    clone.smart_choice_award = false
    clone.nb_comments = 0
    clone.nb_likes = 0
    clone.uploaded_at = newTime if newTime
    puts ">>>>>>>>>>>>> copied photo"
    return clone
  end

  def self.createFromMailgun(params)
    @user = User.find_by_email(params["sender"].downcase)
    puts ">>>>>>"
    puts params["attachment-1"]
    puts @user
    puts ">>>>>>"
    if params["attachment-1"] && @user
      Time.zone = @user.timezone
      @data_point = DataPoint.new
      @data_point.user_id = @user.id
      @data_point.calories = DataPoint.getCaloriesFromMail(params)
      @data_point.description = DataPoint.getDescriptionFromMail(params)
      @data_point.uploaded_at = (params["Date"]) ? params["Date"] : Time.zone.now
      @data_point.photo = params["attachment-1"]
      puts ">>>>>>>>>>>>> created photo from mailgun"

      if @data_point.photo.size >= 4000000
        UserMailer.mail_upload_too_big_file(params["sender"].downcase, params["attachment-1"])
      end

      if @data_point.save
        puts "data point after mailing saved: #{@data_point.inspect}"
        if @user.canPublishOnFacebook?
          @user.fb_publish(@data_point)
        end
      else
        puts "errors while emailing photo: #{@data_point.errors.inspect}"
      end
    elsif !params["attachement-1"]
      UserMailer.mail_upload_no_file(params["sender"].downcase)
    elsif !@user
      UserMailer.mail_upload_no_user(params["sender"].downcase)
    end
  end

  def self.getCaloriesFromMail(params)
    # calories in subject
    return 0 unless params["Subject"]
    match = (params["Subject"]).match(/(\d)+/)
    if match && match[0]
     return match[0]
    else
      return 0
    end

  end

  def self.getDescriptionFromMail(params)
    # description of photo is in mail body
    res = ""
    if params["stripped-text"]
      match = (params["stripped-text"]).match(/"(.*?)"/)
      res = params["stripped-text"].match(/"(.*?)"/)[1]  if (match && match[1])
    end
    return res
  end

end


class DataPoint < ActiveRecord::Base
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
  validates :calories, :presence => true, :numericality => { :only_integer => true }
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
    :convert_options => { :all => '-auto-orient' },
    :storage => :s3,
    :bucket => S3_CREDENTIALS[:bucket],
    :path => ":attachment/:id/:style.:extension",
    :default_url => '/assets/not-available.jpg',
    # :url => ':s3_alias_url',
    # :s3_host_alias => CLOUDFRONT_CREDENTIALS[:host],
    :s3_credentials => S3_CREDENTIALS,
    :s3_permissions => :public_read

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

  def duplicate (newTime)
    clone = self.dup

    clone.photo = self.photo
    clone.hot_photo_award = false
    clone.smart_choice_award = false
    clone.nb_comments = 0
    clone.nb_likes = 0
    clone.uploaded_at = newTime if newTime
    puts ">>>>>>>>>>>>> copied photo"
    return clone
  end

  def group_by_criteria
    if uploaded_at.nil?
      created_at.to_date.to_s(:db)
    else
      uploaded_at.to_date.to_s(:db)
    end
  end

  def group_by_day_of_week
    created_at.strftime("%w")
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
end


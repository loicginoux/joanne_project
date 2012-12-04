class DataPoint < ActiveRecord::Base
  validates :calories, :presence => true, :numericality => { :only_integer => true }
  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than=>3.megabyte
  validates_attachment_content_type :photo, :content_type=>['image/jpeg','image/jpg', 'image/png', 'image/gif']

  has_attached_file :photo,
    :styles => {
      :thumbnail => ["50x50#",:jpg],
      :medium => ["220x220#",:jpg],
      :big => ["380x380#",:jpg]
    },
    :storage => :s3,
    :bucket => S3_CREDENTIALS[:bucket],
    :path => ":attachment/:id/:style.:extension",
    :s3_credentials => S3_CREDENTIALS

  belongs_to :user
  has_many :comments, :dependent => :destroy
  has_many :likes
  has_many :fans, :through => :likes, :source => :user


  # if you are using attr_accessible to protect certain attributes, you will need to allow these:
  # attr_accessible :photo, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at

  def isOwner(user)
    if user
       user.id == self.user.id
    else
      false
    end
  end

end


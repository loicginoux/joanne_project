class DataPoint < ActiveRecord::Base
  validates :calories, :presence => true, :numericality => { :only_integer => true }
  validates_attachment_presence :photo                    
  validates_attachment_size :photo, :less_than=>3.megabyte
  validates_attachment_content_type :photo, :content_type=>['image/jpeg','image/jpg', 'image/png', 'image/gif']
  
  has_attached_file :photo, 
    :styles => {
      :medium => ["200x200#",:jpg]
    },
    :storage => :s3,
    :bucket => S3_CREDENTIALS[:bucket],
    :path => ":attachment/:id/:style.:extension",
    :s3_credentials => S3_CREDENTIALS
    
  belongs_to :user
  

  # if you are using attr_accessible to protect certain attributes, you will need to allow these:
  # attr_accessible :photo, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at
end


class DataPoint < ActiveRecord::Base
  has_attached_file :photo, 
    :styles => {
      :thumb  => "100x100",
      :medium => "200x200"
    },
    :storage => :s3,
    :bucket => "foodrubix-assets",
    :path => ":attachment/:id/:style.:extension",
    :s3_credentials => S3_CREDENTIALS
    
  belongs_to :user
  accepts_nested_attributes_for :user
  
  # if you are using attr_accessible to protect certain attributes, you will need to allow these:
  # attr_accessible :photo, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at
end


class DataPoint < ActiveRecord::Base
  has_attached_file :photo
  belongs_to :user
  accepts_nested_attributes_for :user
end


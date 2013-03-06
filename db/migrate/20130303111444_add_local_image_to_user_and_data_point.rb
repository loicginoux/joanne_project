class AddLocalImageToUserAndDataPoint < ActiveRecord::Migration
	def self.up
    add_attachment :users, :local_picture
    add_attachment :data_points, :local_photo
  end

  def self.down
    remove_attachment :users, :local_picture
    remove_attachment :data_points, :local_photo
  end
end

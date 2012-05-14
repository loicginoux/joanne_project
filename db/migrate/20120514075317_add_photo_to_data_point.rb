class AddPhotoToDataPoint < ActiveRecord::Migration
  def self.up
    change_table :data_points do |t|
      t.has_attached_file :photo
    end
  end

  def self.down
    drop_attached_file :data_points, :photo
  end
end

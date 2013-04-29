class RemoveLocalPicAndRoleToUsers < ActiveRecord::Migration
  def up
  	remove_attachment :users, :local_picture
    remove_attachment :data_points, :local_photo
    remove_column :users, :role
  end

  def down
  	add_attachment :users, :local_picture
    add_attachment :data_points, :local_photo
    add_column :users, :role, :string
  end
end

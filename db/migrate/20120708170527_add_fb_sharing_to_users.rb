class AddFbSharingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fb_sharing, :boolean, :default => false
  end
end

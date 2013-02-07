class AddPrivateToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :hidden, :boolean, :default => false
  	add_column :users, :first_friend, :boolean, :default => false
  end
end

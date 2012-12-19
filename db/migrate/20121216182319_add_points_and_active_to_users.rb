class AddPointsAndActiveToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :active, :boolean, :default => false
  	add_column :users, :leaderboard_points, :integer, :default => 0

  end
end

class AddTotalLeaderboardPointsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :total_leaderboard_points, :integer, :default => 0
  end
end

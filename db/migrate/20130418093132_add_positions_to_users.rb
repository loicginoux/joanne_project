class AddPositionsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :position_total_leaderboard, :integer
  	add_column :users, :position_leaderboard, :integer
  end
end

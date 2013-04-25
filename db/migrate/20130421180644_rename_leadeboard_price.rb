class RenameLeadeboardPrice < ActiveRecord::Migration
  def up
  	remove_index :leaderboard_prices, :user_id
		rename_table :leaderboard_prices, :leaderboard_prizes
		add_index :leaderboard_prizes, :user_id
  end

  def down
  	remove_index :leaderboard_prizes, :user_id
  	rename_table :leaderboard_prices, :leaderboard_prizes
		add_index :leaderboard_prices, :user_id
  end
end
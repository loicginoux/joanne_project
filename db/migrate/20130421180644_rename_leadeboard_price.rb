class RenameLeadeboardPrice < ActiveRecord::Migration
  def up
		rename_table :leaderboard_prices, :leaderboard_prizes
  end

  def down
  	rename_table :leaderboard_prices, :leaderboard_prizes
  end
end

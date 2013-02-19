class CreateLeaderboardPrices < ActiveRecord::Migration
  def change
    create_table :leaderboard_prices do |t|
      t.string :name
      t.references :user

      t.timestamps
    end
    add_index :leaderboard_prices, :user_id
  end
end

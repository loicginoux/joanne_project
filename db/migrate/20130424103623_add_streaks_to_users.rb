class AddStreaksToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :best_daily_score,:default => 0
    add_column :users,  :streak, :default => 0
    add_column :users,  :best_streak, :default => 0
  end
end

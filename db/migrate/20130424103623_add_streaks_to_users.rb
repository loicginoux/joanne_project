class AddStreaksToUsers < ActiveRecord::Migration
  def up
  	add_column :users, :best_daily_score, :integer, :default => 0
    add_column :users,  :streak, :integer, :default => 0
    add_column :users,  :best_streak, :integer, :default => 0
  end
end

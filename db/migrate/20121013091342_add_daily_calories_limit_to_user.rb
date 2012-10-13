class AddDailyCaloriesLimitToUser < ActiveRecord::Migration
  def change
  	    add_column :users, :daily_calories_limit, :integer, :default => 0
  end
end

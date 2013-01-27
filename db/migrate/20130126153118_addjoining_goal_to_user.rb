class AddjoiningGoalToUser < ActiveRecord::Migration
  def change
  	add_column :users, :joining_goal, :text
  end
end

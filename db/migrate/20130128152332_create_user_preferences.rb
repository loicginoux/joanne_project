class CreateUserPreferences < ActiveRecord::Migration
  def change
  	create_table :preferences do |t|
  		t.references :user
  		t.text :joining_goal
  		t.string :coaching_intensity
  		t.boolean :fb_sharing, :default => false
  		t.integer :daily_calories_limit, :default => 0
  		t.boolean  :daily_email,              :default => true
    	t.boolean  :weekly_email,             :default => true
  	end
  end
end

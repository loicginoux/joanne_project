class AddDietAndEatinghabitsToPreferences < ActiveRecord::Migration
  def change
  	add_column :preferences, :diet, :string
  	add_column :preferences, :eating_habits, :text
  end
end

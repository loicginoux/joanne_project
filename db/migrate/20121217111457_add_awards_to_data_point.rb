class AddAwardsToDataPoint < ActiveRecord::Migration
  def change
  	add_column :data_points, :smart_choice_award, :boolean, :default => false
  	add_column :data_points, :hot_photo_award, :boolean, :default => false
  end
end

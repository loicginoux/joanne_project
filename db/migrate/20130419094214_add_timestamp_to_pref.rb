class AddTimestampToPref < ActiveRecord::Migration
  def change
  	add_column :preferences, :created_at, :datetime
    add_column :preferences, :updated_at, :datetime
  end
end

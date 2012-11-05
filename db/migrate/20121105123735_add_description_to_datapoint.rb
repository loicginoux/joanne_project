class AddDescriptionToDatapoint < ActiveRecord::Migration
  def change
  		add_column :data_points, :description, :string, :default => ""
  end
end

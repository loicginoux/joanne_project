class AddDateUploadedToDataPoint < ActiveRecord::Migration
  def change
    add_column :data_points, :uploaded_at, :datetime
  end
end

class AddRelationUserDataPoint < ActiveRecord::Migration
  def change
    add_column :data_points, :user_id, :integer
  end
end

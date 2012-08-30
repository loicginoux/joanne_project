class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :data_point_id
      t.string :text

      t.timestamps
    end
  end
end

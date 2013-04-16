class CreatePoints < ActiveRecord::Migration
	def change
		create_table :points do |t|
			t.references :user
			t.references :friendship
			t.references :comment
			t.references :like
			t.references :data_point
			t.integer :number
			t.date :attribution_date
			t.string :action
			t.timestamps
		end

		add_index :points, :user_id
		add_index :points, :comment_id
		add_index :points, :like_id
		add_index :points, :friendship_id
		add_index :points, :data_point_id
	end

end

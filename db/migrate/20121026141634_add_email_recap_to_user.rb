class AddEmailRecapToUser < ActiveRecord::Migration
	def change
		add_column :users, :daily_email, :boolean, :default => 1
		add_column :users, :weekly_email, :boolean, :default => 1
	end
end

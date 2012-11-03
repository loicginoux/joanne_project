class AddEmailRecapToUser < ActiveRecord::Migration
	def change
		add_column :users, :daily_email, :boolean, :default => true
		add_column :users, :weekly_email, :boolean, :default => true
	end
end

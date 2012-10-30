class AddEmailRecapToUser < ActiveRecord::Migration
	def change
		add_column :users, :email_recap, :string, :default => "Weekly"
	end
end

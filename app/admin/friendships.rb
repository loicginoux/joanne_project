ActiveAdmin.register Friendship do
	index do
		column :id
		column :user
		column :followee
		column :created_at
		default_actions
	end
end

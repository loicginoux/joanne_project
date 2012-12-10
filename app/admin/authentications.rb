ActiveAdmin.register Authentication do
   	index do
		column :id
		column :user
		column :provider
		column :uid
		column :username
		column :access_token
		column :created_at
		column :updated_at
		default_actions
	end
end

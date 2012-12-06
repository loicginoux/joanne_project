ActiveAdmin.register Like do
	index do
		column :id
		column :user
		column :data_point
		column :created_at
		default_actions
	end
end

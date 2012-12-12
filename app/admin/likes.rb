ActiveAdmin.register Like do
	index do
		column :id
		column :user
		column :photo do |like|
      		link_to	like.data_point_id, admin_data_point_path(like.data_point_id)
    	end
		column :created_at
		default_actions
	end
end

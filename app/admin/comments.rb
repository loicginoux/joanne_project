ActiveAdmin.register Comment, :as => "photo comments" do
  	index do
		column :id
		column :user
		column :photo do |comment|
      		link_to	comment.data_point_id, admin_data_point_path(comment.data_point_id)
    	end
		column :text
		column :created_at
		default_actions
	end
end

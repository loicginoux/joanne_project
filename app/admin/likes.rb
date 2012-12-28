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

	form do |f|
	  f.inputs "Like" do
	    # add your other inputs
	    f.input :user, :collection => User.all.map{ |user| [user.username, user.id] }
	    f.input :data_point, :collection => DataPoint.all.map{ |dp| [dp.id, dp.id] }
	    f.buttons
  	end
	end
end

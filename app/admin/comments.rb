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


	form do |f|
		f.inputs "Comment" do
	    # add your other inputs
		    f.input :user, :collection => User.all.map{ |user| [user.username, user.id] }
		    f.input :data_point, :collection => DataPoint.all.map{ |dp| [dp.id, dp.id] }
		    f.buttons
  		end
	end
end

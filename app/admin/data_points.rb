ActiveAdmin.register DataPoint do
	index do
		column :id
		column :user
		column :calories
		column :created_at
		column :updated_at
		column :uploaded_at
		column :photo do |datapoint|
      		getPhoto(datapoint, "thumbnail")
    	end
		default_actions
	end



end

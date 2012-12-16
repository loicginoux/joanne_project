ActiveAdmin.register DataPoint do
	batch_action :delete do |selection|
      DataPoint.find(selection).each do |dp|
        dp.destroy
      end
    end
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

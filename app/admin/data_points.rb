ActiveAdmin.register DataPoint do
	batch_action :delete do |selection|
      DataPoint.find(selection).each do |dp|
        dp.destroy
      end
    end
    scope :all
    scope :hot_photo_awarded
	scope :smart_choice_awarded

	index do
		column :id
		column :user
		column :calories
		column :award do |datapoint|
			award = ""
			award = "Hot Photo" if datapoint.hot_photo_award
			award = "Smart Choice" if datapoint.smart_choice_award
			award
    	end
		column :uploaded_at
		column :photo do |datapoint|
      		getPhoto(datapoint, "thumbnail")
    	end
		default_actions
	end



end

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
		column :description
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

	# show do
	# 	panel "Photo Details" do
	# 		attributes_table_for DataPoint do
	# 			row("Status") { DataPoint.id }
	# 			row("Title") { DataPoint.user }
	# 			row("Project") { DataPoint.calories }
	# 		end
	# 	end
	# 	active_admin_comments
 #    end

	show do
		panel "Photo Details" do
			attributes_table_for DataPoint.find(params[:id]),
				:id,
				:user,
				:calories,
				:description,
				:smart_choice_award,
				:hot_photo_award,
				:created_at,
				:updated_at,
				:uploaded_at,
				:photo_file_name,
				:photo_content_type,
				:nb_comments,
				:nb_likes,
				:photo do
					 row("Photo") { getPhoto(DataPoint.find(params[:id]), "big")}

				end
        end

	end


end

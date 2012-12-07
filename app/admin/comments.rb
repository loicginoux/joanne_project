ActiveAdmin.register Comment, :as => "photo comments" do
  	index do
		column :id
		column :user
		column :data_point
		column :text
		column :created_at
		default_actions
	end
end

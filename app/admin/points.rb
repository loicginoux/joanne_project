ActiveAdmin.register Point do

	filter :user
	filter :action, :as => :select, :collection => Point::ACTION_TYPE
	filter :attribution_date
	index do
		column :id
		column "Nb points" do |p|
			p.number
		end
		column :user
		column :action
		column :attribution_date
		default_actions
	end
end

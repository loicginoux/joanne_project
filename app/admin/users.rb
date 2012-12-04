ActiveAdmin.register User do
	before_filter :only => [:show, :edit, :update, :destroy] do
		@user = User.find_by_username(params[:id])
	end
	index do
		column :id
		column :username
		column :email
		column :confirmed
		default_actions
	end


	form do |f|
		f.inputs "User Details" do
			f.input :email
		end
		f.buttons
	end
end

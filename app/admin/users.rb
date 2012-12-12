ActiveAdmin.register User do
	scope :unconfirmed

	before_filter :only => [:show, :edit, :update, :destroy] do
		@user = User.find_by_username(params[:id])
	end

	index do
		column :id
		column :username
		column :email
		column :confirmed
		column :fb_sharing
		column :daily_email
		column :weekly_email
		column :fb_sharing
		column :timezone
		column "nb photos" do |user|
			user.data_points.count
		end
		default_actions
	end


	form do |f|
		f.inputs "User Details" do
			f.input :email
			f.input :confirmed
			f.input :timezone
			f.input :password
			f.input :password_confirmation
		end
		f.buttons
	end
end

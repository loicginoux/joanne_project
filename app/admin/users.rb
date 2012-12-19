ActiveAdmin.register User do
	scope :all
	scope :unconfirmed
	scope :inactive

	before_filter :only => [:show, :edit, :update, :destroy] do
		@user = User.find_by_username(params[:id])
	end

	index do
		column :id
		column :username
		column :email
		column :leaderboard_points
		column "nb photos" do |user|
			user.data_points.count
		end
		column :confirmed
		column :active
		column :fb_sharing
		column :daily_calories_limit
		column :daily_email
		column :weekly_email
		column :fb_sharing
		column :timezone

		default_actions
	end


	form do |f|
		f.inputs "User Details" do
			f.input :email
			f.input :confirmed
			f.input :active
			f.input :daily_calories_limit
			f.input :daily_email
			f.input :weekly_email
			f.input :timezone
			f.input :password
			f.input :password_confirmation
		end
		f.buttons
	end
end

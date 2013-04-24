ActiveAdmin.register User do
	scope :all
	scope :unconfirmed
	scope :inactive
	scope :joined, :default => true do |users|
		users.includes [:preference]
	end
	before_filter :only => [:show, :edit, :update, :destroy] do
		@user = User.find_by_username(params[:id])
	end

	index do
		column :id
		column :username
		column :email
		column "Points", :leaderboard_points
		column "nb photos" do |user|
			user.data_points.count
		end
		column "coaching", :sortable => "preferences.coaching_intensity" do |u|
			u.preference.coaching_intensity
		end
		column :confirmed
		column :active
		column "fb sharing", :sortable => "preferences.fb_sharing" do |u|
			u.preference.fb_sharing
		end
		column "calories limit", :sortable => "preferences.daily_calories_limit" do |u|
			u.preference.daily_calories_limit
		end
		column "daily email", :sortable => "preferences.daily_email"  do |u|
			u.preference.daily_email
		end
		column "weekly email", :sortable => "preferences.weekly_email" do |u|
			u.preference.weekly_email
		end
		column "Last login date", :sortable => :last_login_at do |u|
			u.last_login_at
		end
		column :timezone

		default_actions
	end


	form do |f|
		f.inputs "User Details" do
			f.input :email
			f.input :confirmed
			f.input :active
			f.input :timezone
			f.input :password
			f.input :password_confirmation
			f.input :first_friend, :label=> "if checked, you will be automatically added to users as their first friend"
			f.input :hidden, :label=> "if checked, you will be hidden from the leaderboard"
		end
		f.buttons
	end


	show do |user|
		attributes_table do
			row :picture do |u|
				getPicture(u, "small")
			end
			row :username
			row :email
			row :created_at
			row :updated_at
			row :confirmed
			row "fb_sharing" do |u|
				u.preference.fb_sharing
			end
			row :timezone
			row "daily calories limit" do |u|
				u.preference.daily_calories_limit
			end
			row :last_login_at
			row :login_count
			row :failed_login_count
			row "daily email" do |u|
				u.preference.daily_email
			end
			row "weekly email" do |u|
				u.preference.weekly_email
			end
			row :active
			row :leaderboard_points
			row :total_leaderboard_points
			row "coaching level" do |u|
				u.preference.coaching_intensity
			end
			row "goal" do |u|
				u.preference.joining_goal
			end
			row :hidden
			row :first_friend
			row :best_daily_score
			row :streak
			row :best_streak

		end
	end
end





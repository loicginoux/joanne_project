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
		column "fb sharing" do |u|
			u.preference.fb_sharing
		end
		column "daily calories limit" do |u|
			u.preference.daily_calories_limit
		end
		column "daily email" do |u|
			u.preference.daily_email
		end
		column "weekly email" do |u|
			u.preference.weekly_email
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
			row :hidden
			row :first_friend
		end

		panel "Monthly leaderboard" do
			attributes_table_for(user)do ||
				row :comments do |user|
					user.comments_points(true)
				end
				row :commented_points do |user|
					user.commented_points(true)
				end
				row :likes_points do |user|
					user.likes_points(true)
				end
				row :liked_points do |user|
					user.liked_points(true)
				end
				row :photo_upload_points do |user|
					user.photo_upload_points(true)
				end
				row :followee_points do |user|
					user.followee_points()
				end
				row :follower_points do |user|
					user.follower_points()
				end
				row :profile_photo_points do |user|
					user.profile_photo_points()
				end
				row :daily_calories_limit_points do |user|
					user.daily_calories_limit_points()
				end
				row :fb_sharing_points do |user|
					user.fb_sharing_points()
				end
				row :smart_choice_award_points do |user|
					user.smart_choice_award_points(true)
				end
				row :hot_photo_award_points do |user|
					user.hot_photo_award_points(true)
				end
			end
		end

		panel "Total leaderboard" do
			attributes_table_for(user)do ||
				row :comments do |user|
					user.comments_points()
				end
				row :commented_points do |user|
					user.commented_points()
				end
				row :likes_points do |user|
					user.likes_points()
				end
				row :liked_points do |user|
					user.liked_points()
				end
				row :photo_upload_points do |user|
					user.photo_upload_points()
				end
				row :followee_points do |user|
					user.followee_points()
				end
				row :follower_points do |user|
					user.follower_points()
				end
				row :profile_photo_points do |user|
					user.profile_photo_points()
				end
				row :daily_calories_limit_points do |user|
					user.daily_calories_limit_points()
				end
				row :fb_sharing_points do |user|
					user.fb_sharing_points()
				end
				row :smart_choice_award_points do |user|
					user.smart_choice_award_points()
				end
				row :hot_photo_award_points do |user|
					user.hot_photo_award_points()
				end
			end
		end
	end
end





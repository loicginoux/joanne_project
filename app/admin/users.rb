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
			row :fb_sharing

			row :timezone
			row :daily_calories_limit
			row :login_count
			row :failed_login_count
			row :daily_email
			row :weekly_email
			row :active
			row :leaderboard_points
			row :total_leaderboard_points
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
					user.comments_points(true)
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
					user.comments_points()
				end
			end
		end
	end
end





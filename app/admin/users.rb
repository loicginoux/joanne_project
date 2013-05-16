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
		column "Goal"	do |u|
			u.preference.joining_goal
		end
		column :timezone

		default_actions
	end


	form do |f|
		f.inputs "User Details" do
			f.input :username
			f.input :email
			f.input :confirmed
			f.input :active
			f.input :leaderboard_points
			f.input :total_leaderboard_points
			f.input :timezone
			# f.input :streak
			# f.input :best_streak
			# f.input :best_daily_score
			f.input :password
			f.input :password_confirmation
			f.input :first_friend, :label=> "if checked, you will be automatically added to users as their first friend"
			f.input :hidden, :label=> "if checked, you will be hidden from the leaderboard"
		end

  	f.inputs "Preferences", :for => [:preference, f.object.preference || Preference.new] do |pref|
  		pref.input :daily_email
  		pref.input :weekly_email
  		pref.input :fb_sharing, :label => "Facebook sharing"
  		pref.input :coaching_intensity, :as => :select, :collection => ["low", "medium", "high"]
  		pref.input :daily_calories_limit
  		pref.input :diet
  		pref.input :joining_goal
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
		end

		panel "Monthly leaderboard" do
			attributes_table_for(user)do ||
				row :comments do |user|
					Point.for_user(user).for_current_month().on_comments().map(&:number).inject(:+) || 0
				end
				row :commented_points do |user|
					Point.for_user(user).for_current_month().on_comments_received().map(&:number).inject(:+) || 0
				end
				row :likes_points do |user|
					Point.for_user(user).for_current_month().on_like().map(&:number).inject(:+) || 0
				end
				row :liked_points do |user|
					Point.for_user(user).for_current_month().on_like_received().map(&:number).inject(:+) || 0
				end
				row :photo_upload_points do |user|
					Point.for_user(user).for_current_month().on_photo_uploaded().map(&:number).inject(:+) || 0
				end
				row :followee_points do |user|
					Point.for_user(user).for_current_month().on_follow().map(&:number).inject(:+) || 0
				end
				row :follower_points do |user|
					Point.for_user(user).for_current_month().on_follower().map(&:number).inject(:+) || 0
				end
				row :profile_photo_points do |user|
					Point.for_user(user).for_current_month().on_profile_photo().map(&:number).inject(:+) || 0
				end
				row :daily_calories_limit_points do |user|
					Point.for_user(user).for_current_month().on_daily_calories_limit().map(&:number).inject(:+) || 0
				end
				row :fb_sharing_points do |user|
					Point.for_user(user).for_current_month().on_fb_sharing().map(&:number).inject(:+) || 0
				end
				row :smart_choice_award_points do |user|
					Point.for_user(user).for_current_month().on_hot_photo_award().map(&:number).inject(:+) || 0
				end
				row :hot_photo_award_points do |user|
					Point.for_user(user).for_current_month().on_smart_choice_award().map(&:number).inject(:+) || 0
				end
				row :joining_goale do |user|
					Point.for_user(user).for_current_month().on_joining_goal().map(&:number).inject(:+) || 0
				end
			end
		end

		panel "Total leaderboard" do
			attributes_table_for(user)do ||
				row :comments do |user|
					Point.for_user(user).on_comments().map(&:number).inject(:+) || 0
				end
				row :commented_points do |user|
					Point.for_user(user).on_comments_received().map(&:number).inject(:+) || 0
				end
				row :likes_points do |user|
					Point.for_user(user).on_like().map(&:number).inject(:+) || 0
				end
				row :liked_points do |user|
					Point.for_user(user).on_like_received().map(&:number).inject(:+) || 0
				end
				row :photo_upload_points do |user|
					Point.for_user(user).on_photo_uploaded().map(&:number).inject(:+) || 0
				end
				row :followee_points do |user|
					Point.for_user(user).on_follow().map(&:number).inject(:+) || 0
				end
				row :follower_points do |user|
					Point.for_user(user).on_follower().map(&:number).inject(:+) || 0
				end
				row :profile_photo_points do |user|
					Point.for_user(user).on_profile_photo().map(&:number).inject(:+) || 0
				end
				row :daily_calories_limit_points do |user|
					Point.for_user(user).on_daily_calories_limit().map(&:number).inject(:+) || 0
				end
				row :fb_sharing_points do |user|
					Point.for_user(user).on_fb_sharing().map(&:number).inject(:+) || 0
				end
				row :smart_choice_award_points do |user|
					Point.for_user(user).on_hot_photo_award().map(&:number).inject(:+) || 0
				end
				row :hot_photo_award_points do |user|
					Point.for_user(user).on_smart_choice_award().map(&:number).inject(:+) || 0
				end
				row :hot_photo_award_points do |user|
					Point.for_user(user).on_joining_goal().map(&:number).inject(:+) || 0
				end
			end
		end
	end
end





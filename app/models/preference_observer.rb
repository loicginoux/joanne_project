class PreferenceObserver < ActiveRecord::Observer
	observe :preference
	def before_save(pref)
			points = 0

			if pref.fb_sharing_changed?
				if pref.fb_sharing && !pref.fb_sharing_was
					points += User::LEADERBOARD_ACTION_VALUE[:fb_sharing]
				elsif !pref.fb_sharing && pref.fb_sharing_was
					points -= User::LEADERBOARD_ACTION_VALUE[:fb_sharing]
				end
			end

			if pref.daily_calories_limit_changed?
				if pref.daily_calories_limit > 0 && pref.daily_calories_limit_was == 0
					points += User::LEADERBOARD_ACTION_VALUE[:daily_calories_limit]
				elsif pref.daily_calories_limit == 0 && pref.daily_calories_limit_was > 0
					points -= User::LEADERBOARD_ACTION_VALUE[:daily_calories_limit]
				end
			end
			pref.user.addPoints(points)
	end
end

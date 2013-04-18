class PreferenceObserver < ActiveRecord::Observer
	observe :preference
	def before_save(pref)
		points = 0

		if pref.fb_sharing_changed?
			if pref.fb_sharing && !pref.fb_sharing_was
				Point.create(
					:user => pref.user,
					:number => Point::ACTION_VALUE[:fb_sharing],
					:action => Point::ACTION_TYPE[:fb_sharing]  )
			elsif !pref.fb_sharing && pref.fb_sharing_was
				pref.user.points.where(:action => Point::ACTION_TYPE[:fb_sharing]).destroy_all()
			end
		end

		if pref.joining_goal_changed?
			if pref.joining_goal != "" && pref.joining_goal_was == ""
				Point.create(
					:user => pref.user,
					:number => Point::ACTION_VALUE[:joining_goal],
					:action => Point::ACTION_TYPE[:joining_goal]  )
			elsif pref.joining_goal == "" && pref.joining_goal_was != ""
				pref.user.points.where(:action => Point::ACTION_TYPE[:joining_goal]).destroy_all()
			end
		end

		if pref.daily_calories_limit_changed?
			if pref.daily_calories_limit > 0 && pref.daily_calories_limit_was == 0
				Point.create(
					:user => pref.user,
					:number => Point::ACTION_VALUE[:daily_calories_limit],
					:action => Point::ACTION_TYPE[:daily_calories_limit]  )
			elsif pref.daily_calories_limit == 0 && pref.daily_calories_limit_was > 0
				pref.user.points.where(:action => Point::ACTION_TYPE[:daily_calories_limit]).destroy_all()
			end
		end
		pref.user.addPoints(points)
	end
end

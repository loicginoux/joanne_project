desc "move user preferences to preference table"
task :move_preferences => :environment do
	User.all.each{ |user|
		pref = Preference.new({
			:user_id => user.id,
			:fb_sharing => user.fb_sharing,
			:daily_calories_limit => user.daily_calories_limit,
			:daily_email => user.daily_email,
			:weekly_email => user.weekly_email
		})
		if pref.save
			puts "success for user #{user.id}"
		else
			puts "error user #{user.id}, errors: #{@user.errors.inspect}"
		end
	}

end
# to be sent every hour
# UserMailer.weekly_recap_email will be in charge to send the email
# at 2am on Monday for all users depending on their timezone
desc "send weekly email recap to users"
task :send_weekly_email => :environment do
  puts "sending weekly emails: start at #{Time.now.utc}"
  users = User.includes(:preference)
  	.confirmed()
  	.active()
  	.where("preferences.weekly_email" => true)
  leaderboard_users = User.monthly_leaderboard().limit(20)
  users.each {|user|
  	Time.zone = user.timezone
  	if Time.zone.now.monday? && Time.zone.now.hour == 7
			UserMailer.weekly_recap_email(user, leaderboard_users)
		end
	}
	puts "sending weekly emails: done"
end

# to be sent every hour
# UserMailer.daily_recap_email will be in charge to send the email
# at 2am for all users depending on their timezone
desc "send daily email recap to users"
task :send_daily_email => :environment do
  puts "sending daily emails: start at #{Time.now.utc}"
  users = User.includes(:preference)
  	.confirmed()
  	.active()
  	.where("preferences.daily_email" => true)
  leaderboard_users = User.monthly_leaderboard().limit(20)
  users.each {|user|
    Time.zone = user.timezone
    if Time.zone.now.hour == 7
  		UserMailer.daily_recap_email(user, leaderboard_users)
    end
  }
	puts "sending daily email: done"
end
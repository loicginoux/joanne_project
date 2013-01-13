# to be sent every hour
# UserMailer.weekly_recap_email will be in charge to send the email
# at 2am on Monday for all users depending on their timezone
desc "send weekly email recap to users"
task :send_weekly_email => :environment do
  	puts "sending weekly emails: start at #{Time.now.utc}"
	users = User.confirmed().active().where(:weekly_email => true)
	UserMailer.weekly_recap_email(users)
	puts "sending weekly emails: done"
end

# to be sent every hour
# UserMailer.daily_recap_email will be in charge to send the email
# at 2am for all users depending on their timezone
desc "send daily email recap to users"
task :send_daily_email => :environment do
  	puts "sending daily emails: start at #{Time.now.utc}"
	users = User.confirmed().active().where(:daily_email => true)
	UserMailer.daily_recap_email(users)
	puts "sending daily email: done"
end
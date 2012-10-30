desc "send weekly email recap to users"
task :send_weekly_email => :environment do
  	puts "sending weekly emails: start"
  	users = User.where("id IN (?)", [11])
  	# users = User.where(:email_recap => "Weekly")

	UserMailer.weekly_recap_email(users)
	puts "sending weekly emails: done"
end

desc "send daily email recap to users"
task :send_daily_email => :environment do
  	puts "sending daily emails: start"
	# users = User.where(:email_recap => "Daily")

  	users = User.where("id IN (?)", [11,47])
	UserMailer.daily_recap_email(users)
	puts "sending daily email: done"
end
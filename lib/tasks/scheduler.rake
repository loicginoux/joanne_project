desc "send weekly email recap to users"
task :send_weekly_email => :environment do
  	if Time.now.monday?
		puts "sending weekly emails: start"
  		users = User.where(:weekly_email => true)
		UserMailer.weekly_recap_email(users)
		puts "sending weekly emails: done"
	end
end

desc "send daily email recap to users"
task :send_daily_email => :environment do
  	puts "sending daily emails: start at #{Time.now.utc}"
	users = User.where(:daily_email => true)
	UserMailer.daily_recap_email(users)
	puts "sending daily email: done"
end
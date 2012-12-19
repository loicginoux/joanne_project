desc "send weekly email recap to users"
task :assign_leaderboard_points => :environment do
  	User.all.each{ |user|
  		user.leaderboard_points = user.assign_leaderboard_points()
  		user.save
  	}
end

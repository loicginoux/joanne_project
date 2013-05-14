desc "move points from the user table to the points table"
task :move_points => :environment do
  User.all.each{ |user|
		puts "user: #{user.username}"
		Point.create!(
			:user => user,
			:number => (user.total_leaderboard_points - user.leaderboard_points),
			:action => "total points adjustement",
			:attribution_date => (DateTime.now) - 1.months)
		Point.create!(
			:user => user,
			:number => user.leaderboard_points,
			:action => "monthly points adjustement",
			:attribution_date => DateTime.now)
	}
end
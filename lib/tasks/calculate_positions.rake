
desc "calculate leadership positions"
task :calculate_positions => :environment do
	users = User.confirmed()
    .active()
    .visible()
    .joins(:points)
    .select("users.*, sum(points.number) as pointsNumber")
    .group("users.id")
    .order("pointsNumber desc, username desc")
	users.each_with_index{ |user, index|
		user.position_total_leaderboard = index+1
		user.save
	}

	users = User.confirmed()
    .active()
    .visible()
    .joins(:points)
    .where("points.attribution_date" => (DateTime.now.beginning_of_month)..(DateTime.now.end_of_month))
    .select("users.*, sum(points.number) as pointsNumber")
    .group("users.id")
    .order("pointsNumber desc, username desc")

	users.each_with_index{ |user, index|
		user.position_leaderboard = index+1
		user.save
	}
end
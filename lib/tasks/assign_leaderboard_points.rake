desc "assign leader board points"
task :assign_leaderboard_points => :environment do
  	User.all.each{ |user|
      points = user.assign_leaderboard_points()
  		monthly_points = user.assign_leaderboard_points(true)
  		user.update_attributes(:leaderboard_points => monthly_points, :total_leaderboard_points => points )
  	}
end

desc "reset monthly leader board points"
task :reset_leaderboard_points => :environment do


    # first of each month
    if Date.today == Date.today.at_beginning_of_month
      winner = User.monthly_leaderboard().first
      price = LeaderboardPrice.new(
        :user_id => winner.id,
        :name => "Winner #{(Date.today - 1.month).strftime("%B %Y")}"
      )
      price.save()
      User.all.each{ |user|
        points = 0
        points += user.followee_points() +
          user.follower_points() +
          user.profile_photo_points() +
          user.daily_calories_limit_points() +
          user.fb_sharing_points()
        user.update_attributes(:leaderboard_points => points )
        puts "resetting monthly points to #{user.username} (#{user.id}): #{points} "
      }
    end

end
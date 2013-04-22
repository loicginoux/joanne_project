desc "reset monthly leaderboard points"
task :reset_leaderboard_points => :environment do
    # first of each month
    if Date.today == Date.today.at_beginning_of_month
      winner = User.monthly_leaderboard().first
      prize = LeaderboardPrize.new(
        :user_id => winner.id,
        :name => "Winner #{(Date.today - 1.month).strftime("%B %Y")}"
      )
      prize.save()
      User.all.each{ |user|
        points = Point.for_user(user).on_start_month().map(&:number).inject(:+) || 0
        user.update_attributes(:leaderboard_points => points )
        puts "resetting monthly points to #{user.username} (#{user.id}): #{points} "
      }
    end

end
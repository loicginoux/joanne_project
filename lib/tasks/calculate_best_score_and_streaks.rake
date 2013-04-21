desc "calculate days points and adjust best score"
task :calculate_best_score => :environment do
  puts "calculating day points: start at #{Time.now.utc}"
  User.confirmed().active().each {|user|
    # we calculate it only for people whose time is midnight
    now = user.timezone.now
    if now.hour == 0
      user.calculate_best_score(now)
    end
  }
	puts "calculating day points: done"
end

desc "calculate streaks"
task :calculate_streaks => :environment do
  puts "calculating streaks: start at #{Time.now.utc}"
  User.confirmed().active().each {|user|
  	now = user.timezone.now
  	# we calculate it only for people whose time is midnight
    if now.hour == 0
    	user.calculate_streaks(now)
  	end
  }
	puts "calculating streaks: done"
end
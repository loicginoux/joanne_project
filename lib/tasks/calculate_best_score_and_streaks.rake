desc "calculate days points and adjust best score"
task :calculate_best_score => :environment do
  puts "calculating day points: start at #{Time.now.utc}"
	Point.calculate_best_score()
	puts "calculating day points: done"
end

desc "calculate streaks"
task :calculate_streaks => :environment do
  puts "calculating streaks: start at #{Time.now.utc}"
	DataPoint.calculate_streaks()
	puts "calculating streaks: done"
end
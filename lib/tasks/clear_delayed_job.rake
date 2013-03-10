desc "remove all delayed jobs"
namespace :jobs do
	task :clear => :environment do
		puts "Clearing all background jobs..."
	  Delayed::Job.all do |job|
    	job.destroy
		end
	end
end
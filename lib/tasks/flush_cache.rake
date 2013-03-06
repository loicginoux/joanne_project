desc "flush cache"
namespace :cache do
task :flush => :environment do
	puts "Flush Cache..."
  	require 'dalli'
    dc = Dalli::Client.new
    dc.flush

end
end

namespace :deploy do
  task :after_deploy, [:env, :branch, :commitMessage] => :environment do |t, args|
		Rake::Task['cache:flush'].invoke
  end
end
# if Rake::Task.task_defined?("assets:precompile:nondigest")
#   Rake::Task["assets:precompile:nondigest"].enhance do
#  	  puts "Flush Cache  site..."
#     Rails.cache.clear
#   end
# else
#   Rake::Task["assets:precompile"].enhance do
#     # rails 3.1.1 will clear out Rails.application.config if the env vars
#     # RAILS_GROUP and RAILS_ENV are not defined. We need to reload the
#     # assets environment in this case.
#     # Rake::Task["assets:environment"].invoke if Rake::Task.task_defined?("assets:environment")
#     Rails.cache.clear
#   end
# end
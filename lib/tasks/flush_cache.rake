namespace :deploy do
  task :after_deploy, [:env, :branch, :commitMessage] => :environment do |t, args|
	  puts "Flush Cache on #{args[:env]} site..."
  end
end
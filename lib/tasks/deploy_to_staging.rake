desc "deploy staging branch to staging"
task :to_staging, [:commitMessage] => :environment do |t, args|
	args.with_defaults(:commitMessage => "commit")
	# puts "#{RAILS.root}"
	puts "#{args[:commitMessage]}"
	# `cd #{RAILS.root}`
	puts "rm"
	`git rm -rf public/assets/*`
	puts "precompile"
	`bundle exec rake assets:precompile`
	puts "add"
	`git add .`
	puts "commit"
	`git commit -m "#{args[:commitMessage]}"`
	puts "push"
	`git push staging staging:master`
end
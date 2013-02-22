desc "deploy staging branch to staging"
task :to_staging, [:commitMessage] => :environment do |t, args|
	args.with_defaults(:commitMessage => "commit")
	# `cd #{RAILS.root}`
	puts "rm -rf public/assets/*"
	`git rm -rf public/assets/*`
	puts "bundle exec rake assets:precompile"
	`bundle exec rake assets:precompile`
	puts "git add ."
	`git add .`
	puts "git commit -m '#{args[:commitMessage]}'"
	`git commit -m "#{args[:commitMessage]}" `
	puts "git push staging staging:master"
	`git push staging staging:master`
end
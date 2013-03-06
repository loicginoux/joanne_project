namespace :deploy do
  task :before_deploy, [:env, :branch, :commitMessage] => :environment do |t, args|

		puts "removing public assets..."
		`pwd`
		`git rm -rf public/assets/*`
		# puts "precompiling assets..."
		# `bundle exec rake assets:precompile`
		puts "add to git"
		`git add .`
		puts "commit to git with message: '#{args[:commitMessage]}'"
		`git commit -m "#{args[:commitMessage]}" `
  end
end
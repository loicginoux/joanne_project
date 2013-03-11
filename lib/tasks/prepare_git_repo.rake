namespace :deploy do
  task :before_deploy, [:env, :branch, :commitMessage] => :environment do |t, args|

  	print "Do you want to precompile assets? (y/n) " and STDOUT.flush
    char = $stdin.getc
    if char != ?y && char != ?Y
     	puts "removing public assets..."
			`git rm -rf public/assets/*`
			`rm -rf public/assets/*`
			puts "precompiling assets..."
			`bundle exec rake assets:precompile`
    end

		puts "add to git"
		`git add .`
		puts "commit to git with message: '#{args[:commitMessage]}'"
		`git commit -m "#{args[:commitMessage]}" `
  end
end
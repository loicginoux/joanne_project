namespace :deploy do
  task :before_deploy, [:env, :branch, :commitMessage] => :environment do |t, args|
  	# print "Do you want to precompile assets? (y/n) " and STDOUT.flush
    # char = $stdin.getc
    # if char == ?y || char == ?Y
     	# puts "removing public assets..."
			# `git rm -rf public/assets/*`
			# `rm -rf public/assets/*`
			puts "precompiling assets..."

			s3_config_file = File.join(Rails.root,'config','s3.yml')
    	raise "#{s3_config_file} is missing!" unless File.exists? s3_config_file
    	S3_CREDENTIALS = YAML.load_file(s3_config_file)[Rails.env].symbolize_keys

			system("bundle exec rake assets:clean_expired RAILS_ENV=#{args[:env]} AWS_ACCESS_KEY_ID=#{S3_CREDENTIALS[:access_key_id]} AWS_SECRET_ACCESS_KEY=#{S3_CREDENTIALS[:secret_access_key]}")
			system("bundle exec rake assets:precompile RAILS_ENV=#{args[:env]} AWS_ACCESS_KEY_ID=#{S3_CREDENTIALS[:access_key_id]} AWS_SECRET_ACCESS_KEY=#{S3_CREDENTIALS[:secret_access_key]}")
    # end

		puts "add to git"
		`git add .`
		`git rm $(git ls-files --deleted)`
		puts "commit to git with message: '#{args[:commitMessage]}'"
		`git commit -m "#{args[:commitMessage]}" `
  end
end
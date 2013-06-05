namespace :s3 do
  require 'aws/s3'
  require 'aws-sdk'

	desc "update user picture name"
	task :change_pics => :environment do

		if Rails.env == "production" || Rails.env == "staging"
		  # set credentials from ENV hash
		  S3_CREDENTIALS = { :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
		  	:secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
		  	:bucket => ENV["S3_BUCKET_NAME"]}
		  else
		  # get credentials from YML file
		  s3_config_file = File.join(Rails.root,'config','s3.yml')
		  raise "#{s3_config_file} is missing!" unless File.exists? s3_config_file
		  S3_CREDENTIALS = YAML.load_file(s3_config_file)[Rails.env].symbolize_keys
		end
	    #
	    #
	  s3 = AWS::S3::new(
	    :access_key_id     => S3_CREDENTIALS[:access_key_id],
	    :secret_access_key => S3_CREDENTIALS[:secret_access_key]
	  )

		bucket = s3.buckets[S3_CREDENTIALS[:bucket]]

	  User.all.each { |u|
	  	id = u.id
	  	pic_updated_at = u.picture.updated_at
	  	puts " "
	  	puts "#{id}, #{pic_updated_at}"
	  	userFolder = "pictures/#{id}"
			if !pic_updated_at.nil?
	  		puts userFolder
	  		obj = bucket.objects['#{userFolder}/small.jpg']
	  		puts obj.exists?
	  		if obj.exists?
	  			 obj.copy_to('#{userFolder}/small_#{pic_updated_at.to_time.to_i}.jpg')
	  		end
	  	end
	  	# if !pic_updated_at.nil? && AWS::S3::S3Object.exists?("small.jpg", userFolder)
	  	# 	puts "process small"
	  	# 	AWS::S3::S3Object.copy?("small.jpg", "small_#{pic_updated_at.to_time.to_i}.jpg",  userFolder)
	  	# end
	  	# if !pic_updated_at.nil? && AWS::S3::S3Object.exists?("medium.jpg", userFolder)
	  	# 	puts "process medium"
	  	# 	AWS::S3::S3Object.copy? "medium.jpg", "medium_#{pic_updated_at.to_time.to_i}.jpg",  userFolder
	  	# end
	  }

	end
end
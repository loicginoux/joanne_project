desc "change the uploaded time for all photos"
task :move_photos => :environment do
	User.all.each{ |user|
		Time.zone = user.timezone
		diff = Time.zone.now.time_zone.utc_offset/60/60
		puts ">>>>>>>user: #{user.username}"
		puts "diff: #{user.username}"
		user.data_points.where("uploaded_at IS NOT null").each{ |dp|
			newDp = dp.uploaded_at + diff.hours
			puts "changed #{dp.id}"
			dp.uploaded_at = dp.uploaded_at + diff.hours
			dp.save
		}
	}

end
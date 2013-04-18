# this was used to fix a bug and shouldn't be used anymore
desc "change the uploaded time for all photos"
task :move_photos => :environment do
	User.where("username != 'joanne'").where("username != 'loknackie'").each{ |user|
		Time.zone = user.timezone
		diff = Time.zone.now.time_zone.utc_offset/60/60
		puts ">>>>>>>user: #{user.username}"
		puts "diff: #{user.username}"
		user.data_points.where("uploaded_at IS NOT null").where(:uploaded_at => (DateTime.now - 1.year) .. (DateTime.now - 5.hours)).each{ |dp|
			newDp = dp.uploaded_at + diff.hours
			puts "changed #{dp.id}"
			dp.uploaded_at = dp.uploaded_at + diff.hours
			dp.save
		}
	}

end
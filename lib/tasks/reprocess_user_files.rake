desc "reprocess user picture"
task :reprocess_user_picture => :environment do
  puts "reprocess start"
  users = User.all
  users.each {|user|
    if user.picture.exists?
      puts "processing #{user.username}"
      user.picture.reprocess!
		end
	}
	puts "reprocess end"
end

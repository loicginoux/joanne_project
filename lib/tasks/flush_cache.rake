HEROKU_APP = {
  :staging => 'calm-gorge-1213',
  :production => 'quiet-summer-5721'
}

desc "flush cache"
namespace :cache do
	task :flush => :environment do
		puts "Flushing Cache..."
	  	require 'dalli'
	    dc = Dalli::Client.new
	    dc.flush
	end
end



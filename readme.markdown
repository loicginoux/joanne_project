Notes for starting in development mode:

"zeus start" for ultra fast commands
"zeus server -p 5000" will start the server
"bundle exec guard" for watching files changes
"memecached -vv" if you want to test with cache. You will need to enable it in config file development.rb
"bundle exec spork rspec" or "bundle exec spork cucumber" to start spork server when testing
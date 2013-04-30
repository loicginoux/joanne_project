source 'https://rubygems.org'

gem 'rails', '3.2.12'


group :development, :test do
    gem 'sqlite3'
    gem 'rspec-rails'
    gem 'pry-rails'
end


# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
group :development do
  gem 'sqlite3'
  # To use debugger
  # gem 'ruby-debug19', :require => 'ruby-debug'
  # debug in chrome inspector
  gem 'meta_request'
  # guard to automate background tasks on file changes
  # see railscast episode 264
  # gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-livereload'

  gem 'factory_girl_rails', :require => false

end

group :test, :darwin do
  gem 'rb-fsevent'
end

group :production, :staging do
  gem 'pg'
  # Use unicorn as the app server
  gem 'unicorn'
end

group :production, :staging, :development do
  #better sql logging
  gem "hirb"

  # better active record print
  gem "awesome_print"
  # scheduled cron jobs
  gem 'whenever', :require => false

  # Application Performance Monitoring
  gem 'newrelic_rpm'

  # memcache
  # gem 'memcachier'
  gem 'dalli'
  # gem 'dalli-store-extensions', :git => "git://github.com/defconomicron/dalli-store-extensions.git"


  # better fragment caching
  gem 'cache_digests'
end

group :test do
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'shoulda'
  gem "lorem-ipsum"
  gem "launchy"
  gem "spork-rails"  #use zeus instead

end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
  gem 'turbo-sprockets-rails3'
end


# admin panel
gem 'activeadmin'
gem "meta_search",    '>= 1.1.0.pre'


gem 'jquery-rails'


#authentification system
gem 'authlogic'

# facebook functionnalities
gem 'omniauth'
gem 'fb_graph'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
#static pages
gem "high_voltage"

#file management
gem "paperclip", "~> 3.1.3"
gem "cocaine", "= 0.3.2"
# file storage amazon s3
gem 'aws-s3'
gem 'aws-sdk'




gem "rest-client"

#pagination
gem 'will_paginate', '~> 3.0'

#passing rails variable to js
gem 'gon'



# more robust web server that webrick (default)
# gem 'thin'




# synh assets to S3
gem "asset_sync"

# asynchronous jobs
# gem 'daemons'
# gem 'delayed_job_active_record'


# better management of heroku worker process
# gem 'hirefire'
# gem "workless"


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'


# Deploy with Capistrano
# gem 'capistrano'





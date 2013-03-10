Foodrubix::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false #true on prod or staging


  # caching
  # config.cache_store = :dalli_store
  # config.static_cache_control = "public, max-age=2592000"
  # config.action_dispatch.rack_cache = {
  #   :metastore    => Dalli::Client.new,
  #   :entitystore  => 'file:tmp/cache/rack/body',
  #   :allow_reload => false
  # }

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # serve assets from public directory
  config.serve_static_assets = false

  # Expands the lines which load the assets
  config.assets.debug = false

  Paperclip.options[:command_path] = "/usr/local/ImageMagick-6.7.5/bin/"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( application-ie9.js, homepage.css )
  config.assets.precompile += ['application-ie9.js', 'homepage.css']


  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = "http://0.0.0.0:5000"
  # config.action_controller.asset_host = "//#{CLOUDFRONT_CREDENTIALS[:host]}"

  config.action_mailer.asset_host = config.action_controller.asset_host

  # email configuration
  config.action_mailer.default_url_options = { :host => config.action_controller.asset_host }
  Rails.application.routes.default_url_options = config.action_mailer.default_url_options

  # logs in unicorn server
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger.const_get(
    ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].upcase : 'DEBUG'
  )

  # worker configuration with delayed_job + workless
  config.after_initialize do
    Delayed::Job.scaler = :local
  end
end

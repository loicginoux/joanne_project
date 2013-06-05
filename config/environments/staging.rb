require_relative '../initializers/cloudfront'
require_relative '../initializers/s3'

Foodrubix::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true
  config.gzip_compression = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # caching
  config.cache_store = :dalli_store
  config.static_cache_control = "public, max-age=2592000"

  config.action_dispatch.rack_cache = {
    :metastore    => Dalli::Client.new,
    :entitystore  => 'file:tmp/cache/rack/body',
    :allow_reload => false
  }

  # Generate digests for assets URLs
  config.assets.digest = true

  # Expands the lines which load the assets
  config.assets.debug = false

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :debug

  # logs in unicorn server
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger.const_get(
    ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].upcase : 'DEBUG'
  )
  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "//calm-gorge-1213.herokuapp.com"
  # config.action_controller.asset_host = "//foodrubix-testing.s3.amazonaws.com"
  config.action_controller.asset_host = "//#{CLOUDFRONT_CREDENTIALS[:host]}"

  config.action_mailer.asset_host = config.action_controller.asset_host

  # email configuration
  config.action_mailer.default_url_options = {
    :host => "calm-gorge-1213.herokuapp.com",
    :only_path => false
  }
  Rails.application.routes.default_url_options = {
    :host => "calm-gorge-1213.herokuapp.com"
  }

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += ['application-ie9.js','homepage.js', 'homepage.css', "application-ie.css", "active_admin.js", "active_admin.css"]
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  #because of bug on heroku about precompliling assets
  #https://devcenter.heroku.com/articles/rails3x-asset-pipeline-cedar#troubleshooting
  config.assets.initialize_on_precompile = false

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # worker configuration with delayed_job + workless
  # config.after_initialize do
  #   Delayed::Job.scaler = :heroku_cedar
  # end

  # paperclip options
  config.paperclip_defaults = {
    :convert_options => { :all => '-auto-orient' },
    :storage => :s3,
    :bucket => S3_CREDENTIALS[:bucket],
    :s3_credentials => S3_CREDENTIALS,
    :path => ":attachment/:id/:style_:updated_at.:extension",
    :default_url => '/assets/default_user_:style.gif',
    :url => ':s3_alias_url',
    :s3_host_alias => CLOUDFRONT_CREDENTIALS[:host],
    :s3_permissions => :public_read
  }
end

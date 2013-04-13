AssetSync.configure do |config|
  # get credentials from YML file
  asset_sync_config_file = File.join(Rails.root,'config','asset_sync.yml')
  raise "#{asset_sync_config_file} is missing!" unless File.exists? asset_sync_config_file
  credentials = YAML.load_file(asset_sync_config_file)[Rails.env].symbolize_keys

  s3_config_file = File.join(Rails.root,'config','s3.yml')
  raise "#{s3_config_file} is missing!" unless File.exists? s3_config_file
  S3_CREDENTIALS = YAML.load_file(s3_config_file)[Rails.env].symbolize_keys

  config.enabled = credentials[:enabled]
  config.fog_provider = credentials[:fog_provider]
  config.fog_directory = credentials[:fog_directory]
  config.existing_remote_files = credentials[:existing_remote_files]
  config.gzip_compression = credentials[:gzip_compression]

  if Rails.env == "production" || Rails.env == "staging"
    config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
    config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  else
    config.aws_access_key_id = S3_CREDENTIALS[:access_key_id]
    config.aws_secret_access_key = S3_CREDENTIALS[:secret_access_key]
  end
  # config.fog_region = 'eu-west-1'
  #
  # Don't delete files from the store
  # config.existing_remote_files = "keep"
  #
  # Automatically replace files with their equivalent gzip compressed version
  # config.gzip_compression = true
  #
  # Use the Rails generated 'manifest.yml' file to produce the list of files to
  # upload instead of searching the assets directory.
  # config.manifest = true
  #
  # Fail silently.  Useful for environments such as Heroku
  # config.fail_silently = true
end

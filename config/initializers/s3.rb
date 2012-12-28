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

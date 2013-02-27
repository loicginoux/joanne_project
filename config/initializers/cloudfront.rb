# get credentials from YML file
cloudfront_config_file = File.join(Rails.root,'config','cloudfront.yml')
raise "#{cloudfront_config_file} is missing!" unless File.exists? cloudfront_config_file
CLOUDFRONT_CREDENTIALS = YAML.load_file(cloudfront_config_file)[Rails.env].symbolize_keys

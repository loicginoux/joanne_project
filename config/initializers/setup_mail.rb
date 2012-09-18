if Rails.env == "production"
  # set credentials from ENV hash
  MAILGUN = { 
    :api_key => ENV['MAILGUN_API_KEY'], 
    :api_url => "https://api:#{ENV['MAILGUN_API_KEY']}@api.mailgun.net/v2/foodrubix.mailgun.org",
    :admin_mailbox => "foodrubix@foodrubix.mailgun.org"
  }
else
  # get credentials from YML file
  mailgun_config_file = File.join(Rails.root,'config','mailgun.yml')
  raise "#{mailgun_config_file} is missing!" unless File.exists? mailgun_config_file
  MAILGUN = YAML.load_file(mailgun_config_file)[Rails.env].symbolize_keys
end
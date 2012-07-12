facebook_config_file = File.join(Rails.root,'config','facebook.yml')
raise "#{facebook_config_file} is missing!" unless File.exists? facebook_config_file
FB_CONFIG = YAML.load_file(facebook_config_file)[Rails.env].symbolize_keys

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FB_CONFIG[:fb_app_id], FB_CONFIG[:secret_access_key] ,
          :scope => %(email, publish_stream)
  provider :twitter, 'NzRDtueA50fYl7HxWv00Ow', 'pdiJqwaT1awEhVTehuJ7R9qJKXP92AcuuQlUnVlEg'
end
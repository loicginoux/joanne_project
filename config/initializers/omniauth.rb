Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '445409062150241', '997dc180be8d351ff126d4a97009c26e' ,
          :scope => %(email, publish_stream)
  provider :twitter, 'NzRDtueA50fYl7HxWv00Ow', 'pdiJqwaT1awEhVTehuJ7R9qJKXP92AcuuQlUnVlEg'
end
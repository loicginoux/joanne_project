Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '445409062150241', '997dc180be8d351ff126d4a97009c26e' ,
          :scope => %(email user_birthday user_photos, friends_photos, read_mailbox, publish_stream offline_access)
  provider :twitter, 'NzRDtueA50fYl7HxWv00Ow', 'pdiJqwaT1awEhVTehuJ7R9qJKXP92AcuuQlUnVlEg'
end
ActionMailer::Base.smtp_settings = {  
  :address              => "smtp.gmail.com",  
  :port                 => 587,  
  :domain               => "foodrubix.com",  
  :user_name            => "lgxtodo@gmail.com",  
  :password             => "pigaloma",  
  :authentication       => "plain",  
  :enable_starttls_auto => true  ,
  :openssl_verify_mode  => OpenSSL::SSL::VERIFY_NONE
}
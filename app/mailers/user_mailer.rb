class UserMailer < ActionMailer::Base
  default :from => "lgxtodo@gmail.com"
  
  def reset_password_email(user)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail(:to => user.email, :subject => "[Your App] Password Reset")
  end
   
  def welcome_email(user)
     @user = user
     @url  = "http://example.com/login"
     mail(:to => user.email, :subject => "Welcome to My Awesome Site")
   end

 
end

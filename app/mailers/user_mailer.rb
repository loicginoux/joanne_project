class UserMailer < ActionMailer::Base
  default :from => "lginoux.pro@gmail.com"

  def reset_password_email(user)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail(:to => user.email, :subject => "[FoodRubix] Password Reset")
  end

  def verify_account_email(user)
    logger.info user
    @user_verification_url = user_verification_url(user.perishable_token)
    mail(:to => user.email, :subject => "[FoodRubix] Verify your account")
  end


end

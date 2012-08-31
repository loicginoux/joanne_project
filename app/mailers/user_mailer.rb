class UserMailer < ActionMailer::Base
  default :from => "lginoux.pro@gmail.com"

  def reset_password_email(user)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail(:to => user.email, :subject => "[FoodRubix] Password Reset")
  end

  def verify_account_email(user)
    @user_verification_url = user_verification_url(user.perishable_token)
    mail(:to => user.email, :subject => "[FoodRubix] Verify your account")
  end

  def added_comment_email(dataPoint, comment)
    @dataPoint = dataPoint
    @comment = comment
    mail(:to => dataPoint.user.email, :subject => "[FoodRubix] new comment on your meal")
  end
  
  def added_like_email(dataPoint, like)
    @dataPoint = dataPoint
    @like = like
    mail(:to => like.user.email, :subject => "[FoodRubix] someone like your meal")
  end
end

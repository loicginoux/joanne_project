class UserVerificationsController < ApplicationController
  before_filter :load_user_using_perishable_token

  def show
    if @user
      @user.verify!
      flash[:notice] = "Thank you for verifying your account. You may now login."
    end
    redirect_to login_path
  end

  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
      flash[:notice] = "We're sorry, but we could not locate your account. "
      redirect_to static_path("home")  
    end
  end
end

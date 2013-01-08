class UserVerificationsController < ApplicationController
  before_filter :load_user_using_perishable_token

  def show
    if @user
      if @user.verify!
        flash[:notice] = "Thank you for verifying your account. You may now log in."
      else
        flash[:notice] = "Account verification impossible."
      end
      redirect_to login_path
    end
  end

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      pendingUser = User.where(:perishable_token => params[:id]).first
      puts ">>>>>>>>>>"
      puts pendingUser
      pendingUser.destroy() if pendingUser
      flash[:notice] = "We're sorry, but you verified your account too late. you had one hour to verify it. Please restart the registration process."
      redirect_to register_path
    end
  end
end

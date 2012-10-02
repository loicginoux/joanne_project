class HomeRedirectController < ApplicationController

  def show
    if current_user
      redirect_to user_path(:username=> current_user.username)
    else
      redirect_to static_path("home")
    end
  end

end

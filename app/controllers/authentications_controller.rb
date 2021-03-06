class AuthenticationsController < ApplicationController


  def create
    omniauth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    if authentication
      # User is already registered with application
      flash[:info] = 'Signed in successfully.'
      #  we update his token in case of expiry
      authentication.update_attributes(:access_token => omniauth["credentials"]["token"])
      sign_in_and_redirect(authentication.user)

    elsif current_user
      # User is signed in but has not already authenticated with this social network
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :username => omniauth['extra']['raw_info']['username'] , :access_token => omniauth["credentials"]['token'])
      current_user.apply_omniauth(omniauth)
      current_user.save
      flash[:info] = 'Authentication successful.'
      sign_in_and_redirect(current_user)
    else
      # User is new to this application
      user = User.new
      user.authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'], :username => omniauth['extra']['raw_info']['username'] , :access_token => omniauth["credentials"]['token'])
      user.apply_omniauth(omniauth)
      if user.save
        flash[:info] = 'User created and signed in successfully.'
        sign_in_and_redirect(user)
      else
        # session[:omniauth] = omniauth
        puts omniauth
        session[:omniauth] =  {:provider=>omniauth['provider'],
                              :uid => omniauth['uid'],
                              :username => omniauth['extra']['raw_info']['username'] ,
                              :email => omniauth[:info][:email],
                              :access_token => omniauth["credentials"]['token'],
                              :image => omniauth[:info][:image]}
        redirect_to register_path
      end
    end
  end


  private
    def sign_in_and_redirect(user)
      unless current_user
        user_session = UserSession.new(User.find_by_single_access_token(user.single_access_token))
        user_session.save
      end
      # redirect_to user_path(:username=> user.username), notice: 'successfully logged in.'
      redirect_back_or_default(user_path(:username=> user.username))

    end

end

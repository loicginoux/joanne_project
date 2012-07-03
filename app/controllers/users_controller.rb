class UsersController < ApplicationController
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end
    
  def show
     @user = User.first(:conditions => {:username=> params[:username]})
     logger.debug @user.inspect
     logger.debug params[:username]
     logger.debug current_user
     respond_to do |format|
       if @user.isUserAllowed(current_user)
         format.html # show.html.erb
         format.json { render :json => @user }
       else
         format.html { redirect_to login_path, :notice => 'you cannot access this user' }
         format.json { head :ok }

       end
     end
   end
   
  def new
     @user = User.new
     @user.data_points.build
     respond_to do |format|
       format.html # new.html.erb
       format.json { render json: @user }
     end
   end
   
  def create
    @user = User.new(params[:user])
    # we came to registration page from an authentifaction provider page, we redirect here because the password needs to be filled
    if session[:omniauth] 
      #we verify directly the account, no need to verify email
      @user.authentications.build(:provider => session[:omniauth][:provider], :uid => session[:omniauth][:uid])
      if @user.verify! 
        user_session = UserSession.new(User.find_by_single_access_token(@user.single_access_token))
        user_session.save
        redirect_to user_path(:username=> @user.username), notice: 'successfully logged in.'
      else
        render :action => 'new'
      end
    # we register directly a new user
    elsif @user.save
      flash[:notice] = "Thanks for signing up, we've delivered an email to you with instructions on how to complete your registration!"
      @user.deliver_confirm_email_instructions!
      redirect_to static_path("home")
    else
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated profile."
      redirect_to static_path("home")
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @user = User.first(:conditions => {:username=> params[:username]})
    @user.destroy
    respond_to do |format|
      format.html { redirect_to static_path("home") }
      format.json { head :ok }
    end
  end
  
end

class UsersController < ApplicationController
  before_filter :require_login
  before_filter :require_login, :except => [:new, :create]

  layout :resolve_layout


  def index
    # all but yourself and followee
    @users = User.confirmed().without_user(current_user)
    followee_ids = current_user.friendships.map(&:followee_id)
    @users = @users.without_followees(followee_ids).paginate(:per_page => 30, :page => params[:users_page])

    @followees = current_user.friendships.paginate(:per_page => 30, :page => params[:followees_page])




    # @groups = User.prepareGroups(@users, 3)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  def show
    @user = User.first(:conditions => {:username=> params[:username]})

    puts @user.inspect
    puts params[:username]
    gon.daily_calories_limit = @user.daily_calories_limit
    if @user.isUserAllowed(current_user)
      gon.isCurrentUserDashboard = true
      gon.last_login_at = current_user.last_login_at
    else
      gon.isCurrentUserDashboard = false
    end
    respond_to do |format|
      if @user
          format.html # show.html.erb
          format.json { render :json => @user }


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
    params[:user][:username] = params[:user][:username].downcase
    puts params[:user]
    @user = User.new(params[:user])
    # we came to registration page from an authentifaction provider page, we redirect here because the password needs to be filled
    if session[:omniauth]
      @user.authentications.build(:provider => session[:omniauth]['provider'], :uid => session[:omniauth]['uid'], :username => session[:omniauth]['extra']['raw_info']['username'] , :access_token => session[:omniauth]["credentials"]['token'])
      #we verify directly the account, no need to verify email
      if @user.verify!
        user_session = UserSession.new(User.find_by_single_access_token(@user.single_access_token))
        user_session.save
        session[:omniauth] = nil
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
      redirect_to edit_user_path(:username=> @user.username), notice: 'Successfully updated profile.'
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

  private

  def resolve_layout
    case action_name
    when "new"
      "home"
    else
      "application"
    end
  end

end

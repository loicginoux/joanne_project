class UsersController < ApplicationController
  before_filter :require_login
  before_filter :require_login, :except => [:new, :create]

  layout :resolve_layout

  helper_method :sort_column, :sort_direction, :nb_total_leaderboard_users_per_page, :nb_leaderboard_users_per_page

  def index
    @total_leaderboard_users = User.total_leaderboard()
      .paginate(:per_page => nb_total_leaderboard_users_per_page, :page => params[:total_leaderboard_page])

    @leaderboard_users = User.monthly_leaderboard()
      .paginate(:per_page => nb_leaderboard_users_per_page, :page => params[:leaderboard_page])

    @slackerboard_users = User.slackerboard()
      .paginate(:per_page => 10, :page => params[:slackerboard_page])

    pos = current_user.positionLeadership()
    @current_user_position = pos.position.to_i
    @current_user_total_position = pos.all_time_position.to_i

    @isInLeaderboard = ((@leaderboard_users.current_page * nb_leaderboard_users_per_page) >=  @current_user_position )
    @isInTotalLeaderboard = ((@total_leaderboard_users.current_page * nb_total_leaderboard_users_per_page) >=  @current_user_total_position )

    @latest_members = User.confirmed()
                          .active()
                          .limit(10)
                          .order("created_at desc")

    if params[:total_leaderboard_page]
      @update = "allTimeLeaderboard"
    elsif params[:leaderboard_page]
      @update = "leaderboard"
    elsif params[:slackerboard_page]
      @update = "slackerboard"
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @user = User.first(:conditions => {:username=> params[:username]})
    if @user
      gon.daily_calories_limit = @user.daily_calories_limit
    end
    if @user && @user.is(current_user)
      gon.isCurrentUserDashboard = true
      gon.last_login_at = current_user.last_login_at
    else
      gon.isCurrentUserDashboard = false
    end
    respond_to do |format|
      if @user
          format.html # show.html.erb
          format.json { render :json => @user }
      else
        if current_user
          format.html {redirect_to user_path(:username=> current_user.username), notice: 'this user does not exist'}
        else
          format.html {redirect_to static_path("home"), notice: 'this user does not exist'}
        end
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
      @user.authentications.build(:provider => session[:omniauth][:provider], :uid => session[:omniauth][:uid], :username => session[:omniauth][:username] , :access_token => session[:omniauth][:access_token])
      if session[:omniauth][:image]
        @user.picture = open(session[:omniauth][:image])
      end
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
      if @user.getEmailProviderUrl()
        flash[:notice] = "Thanks for signing up. Check your email at <i>#{@user.email}</i> to complete the sign-up process.</br>#{ActionController::Base.helpers.link_to "Go to your email", @user.getEmailProviderUrl(), :target => '_blank', :class=>'cta'}".html_safe
      else
        flash[:notice] = "Thanks for signing up. Check your email at <i>#{@user.email}</i> to complete the sign-up process.".html_safe
      end
      @user.deliver_confirm_email_instructions!
      redirect_to static_path("home")
    else
      render :action => 'new'
    end
  end

  def edit
    if current_user
      @user = current_user
      if current_user.username != params[:username]
        redirect_to edit_user_path(:username=> current_user.username), notice: 'You can only edit your profile.'
      end
    end
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
    @user.picture.destroy
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
    when "create"
      "home"
    else
      "application"
    end
  end

  def sort_column
    params[:sort] || "total_leaderboard_points"
  end

  def sort_direction
    params[:direction] || "desc"
  end

  def nb_leaderboard_users_per_page
    15
  end

  def nb_total_leaderboard_users_per_page
    15
  end
end

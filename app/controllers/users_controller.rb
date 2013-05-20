class UsersController < ApplicationController
  before_filter :require_login
  before_filter :require_login, :except => [:new, :create]

  layout :resolve_layout

  helper_method :sort_column, :sort_direction, :nb_total_leaderboard_users_per_page, :nb_leaderboard_users_per_page

  def index
    if params[:total_leaderboard_page]
      @update = "allTimeLeaderboard"
    elsif params[:leaderboard_page]
      @update = "leaderboard"
    elsif params[:slackerboard_page]
      @update = "slackerboard"
    elsif params[:latest_member_page]
      @update = "latestMembers"
    end


    if @update.nil? || @update == "allTimeLeaderboard"
      # filter by diet
      @diet = params[:diet]
      if (@diet && @diet != "")
        @total_leaderboard_users = User.total_leaderboard()
          .where(:"preferences.diet" => Preference::DIETS[params[:diet].to_i] )
          .paginate(:per_page => nb_total_leaderboard_users_per_page,
            :page => params[:total_leaderboard_page])
        # don't show current user position
        @isInTotalLeaderboard = true
      else
        @total_leaderboard_users = User.total_leaderboard()
          .paginate(:per_page => nb_total_leaderboard_users_per_page,
                    :page => params[:total_leaderboard_page])

      end
      # get current user position
      if @isInTotalLeaderboard.nil?
        @current_user_total_position = User.in_leadeboard()
          .where("username <= ?", @current_user.username )
          .where("total_leaderboard_points >= ?", @current_user.total_leaderboard_points )
          .count()
        @isInTotalLeaderboard = ((@total_leaderboard_users.current_page * nb_total_leaderboard_users_per_page) >=  @current_user_total_position )
        puts " "; puts ">>>>>>>>>>>>>>>>>>"
        puts @current_user_total_position
        puts @isInTotalLeaderboard
        puts ">>>>>>>>>>>>>>>>>";puts " "
      end
    end

    if @update.nil? || @update == "leaderboard"
      # get user list
      userList =  User.monthly_leaderboard()
      # filter by diet
      @diet = params[:diet]
      if (@diet && @diet != "")
        @leaderboard_users = User.monthly_leaderboard()
          .where(:"preferences.diet" => Preference::DIETS[params[:diet].to_i] )
        # don't show current user position
        @isInLeaderboard = true
      else
        @leaderboard_users = User.monthly_leaderboard()
          .paginate(
            :per_page => nb_leaderboard_users_per_page,
            :page => params[:leaderboard_page])
      end

      if @isInLeaderboard.nil?
        @current_user_position = User.in_leadeboard().where("leaderboard_points < ?", @current_user.leaderboard_points ).count()
        @isInLeaderboard = ((@leaderboard_users.current_page * nb_leaderboard_users_per_page) >=  @current_user_position )
      end
    end

    if @update.nil? || @update == "slackerboard"
      @slackerboard_users = current_user.slackerboard().paginate(:per_page => 15, :page => params[:slackerboard_page])
    end

    if @update.nil? || @update == "latestMembers"
      @latest_members = User.latest_members().paginate(:per_page => 15, :page => params[:latest_member_page])
    end

    respond_to do |format|
      format.html
      format.js
    end
  end


  def show
    @user = User.includes(:preference).first(:conditions => {:username=> params[:username]})
    if @user
      gon.daily_calories_limit = @user.preference.daily_calories_limit
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
          format.html {redirect_to user_path(:username=> current_user.username)}
        else
          format.html {redirect_to static_path("home")}
        end
      end
    end
  end

  def new
     @user = User.new
     @user.data_points.build
     @user.build_preference
     @url = register_path
     respond_to do |format|
       format.html # new.html.erb
       format.json { render json: @user }
     end
  end

  def create
    params[:user][:username] = params[:user][:username].downcase
    params[:user][:email] = params[:user][:email].downcase
    @user = User.new
    @user.data_points.build
    @user = User.new(params[:user])
    @url = register_path
    # we came to registration page from an authentifaction provider page, we redirect here because the password needs to be filled
    if session[:omniauth]
      @user.authentications.build(:provider => session[:omniauth][:provider], :uid => session[:omniauth][:uid], :username => session[:omniauth][:username] , :access_token => session[:omniauth][:access_token])
      if session[:omniauth][:image]
        # @user.local_picture = open(session[:omniauth][:image])
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
      render
    end
  end

  def edit
    if current_user
      @user = current_user
      @preference = current_user.preference
      @url = edit_user_path(:username=> current_user.username)
      if current_user.username != params[:username]
        redirect_to edit_user_path(:username=> current_user.username), notice: 'You can only edit your profile.'
      end
    end
  end

  def update
    @user = current_user
    @preference = current_user.preference
    @url = edit_user_path(:username=> current_user.username)
    if @user.update_attributes(params[:user])
      redirect_to edit_user_path(:username=> @user.username, :anchor => params[:anchor]), notice: 'Successfully updated profile.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.first(:conditions => {:username=> params[:username]})
    @user.picture.destroy unless @user.picture_file_size.nil?
    # @user.local_picture.destroy unless @user.local_picture_file_size.nil?
    @user.destroy
    respond_to do |format|
      format.html { redirect_to static_path("home") }
      format.json { head :ok }
    end
  end

  def follow
    @followee = User.where(:username => params[:username]).first
    puts @followee.inspect
    respond_to do |format|
      format.html
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

class UserSessionsController < ApplicationController

  layout "home"
  # GET /user_sessions/new
  # GET /user_sessions/new.json
  def new
    @user_session = UserSession.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_session }
    end
  end


  # POST /user_sessions
  # POST /user_sessions.json
  def create
    @user_session = UserSession.new(params[:user_session])
    respond_to do |format|
      if @user_session.save
        user = User.first(:conditions => {:username=> @user_session.username.downcase})
        format.html { redirect_back_or_default(user_path(:username=> user.username))  }
        format.json { render json: @user_session, status: :created, location: @user_session }
      else
        format.html { render action: "new" }
        format.json { render json: @user_session.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.json
  def destroy
    @user_session = UserSession.find
    @user_session.destroy

    respond_to do |format|
      format.html { redirect_to home_path, notice: 'successfully logged out.' }
      format.json { head :ok }
    end
  end

  private

  def resolve_layout
    case action_name
    when "new", "destroy", "index"
      "home"
    else
      "application"
    end
  end

end
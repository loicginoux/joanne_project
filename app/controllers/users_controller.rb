class UsersController < ApplicationController
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end
    
  def new
     @user = User.new
     respond_to do |format|
       format.html # new.html.erb
       format.json { render json: @user_session }
     end
   end
   
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Got it! Can you check your mail account for confirmation."
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
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end

end

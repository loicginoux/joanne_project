class FriendshipsController < ApplicationController
  before_filter :require_login
  
  # GET /friendships
  # GET /friendships.json
  def index
    @friendships = current_user.friendships.paginate(:per_page => 30, :page => params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @friendships }
    end
  end

 
  # POST /friendships
  # POST /friendships.json
  def create
    @friendship = current_user.friendships.build(:followee_id => params[:followee])
     if @friendship.save
       flash[:notice] = "Added friend."
       redirect_to challengers_path
     else
       flash[:notice] = "Unable to add friend."
       redirect_to challengers_path
     end
  end

 
  # DELETE /friendships/1
  # DELETE /friendships/1.json
  def destroy
    @friendship = Friendship.find(params[:id])
    @friendship.destroy

    respond_to do |format|
      format.html { redirect_to users_path }
      format.json { head :no_content }
    end
  end
end

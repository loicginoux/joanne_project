class FriendshipsController < ApplicationController
  # GET /friendships
  # GET /friendships.json
  def index
    @friendships = current_user.friendships
    @groups = Friendship.prepareGroups(@friendships, 4)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

 
  # POST /friendships
  # POST /friendships.json
  def create
    @friendship = current_user.friendships.build(:followee_id => params[:followee])
     if @friendship.save
       flash[:notice] = "Added friend."
       redirect_to people_path
     else
       flash[:notice] = "Unable to add friend."
       redirect_to people_path
     end
  end

 
  # DELETE /friendships/1
  # DELETE /friendships/1.json
  def destroy
    @friendship = Friendship.find(params[:id])
    @friendship.destroy

    respond_to do |format|
      format.html { redirect_to friendships_url }
      format.json { head :no_content }
    end
  end
end

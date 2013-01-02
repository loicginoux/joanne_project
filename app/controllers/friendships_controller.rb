class FriendshipsController < ApplicationController
  before_filter :require_login
  helper_method :sort_column, :sort_direction
  # GET /friendships
  # GET /friendships.json
  def index
    @users = current_user.friendships
      .joins(:followee)
      .order(sort_column + ' ' + sort_direction)
      .map { |f| f.followee unless f.followee_id.nil?}
      .paginate(:per_page => 15, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json {
        render json: @friendships
      }
    end
  end


  # POST /friendships
  # POST /friendships.json
  def create
    @friendship = current_user.friendships.build(:followee_id => params[:followee])
     if @friendship.save
       flash[:notice] = "Added friend."
       redirect_to team_rubix_path
     else
       flash[:notice] = "Unable to add friend."
       redirect_to team_rubix_path
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

  private

  def sort_column
    params[:sort] || "users.leaderboard_points"
  end

  def sort_direction
    params[:direction] || "desc"
  end
end


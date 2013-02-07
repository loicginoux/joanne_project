class FriendshipsController < ApplicationController
  before_filter :require_login

  # GET /friendships
  # GET /friendships.json
  def index
    @update = params[:update]
    if params[:user_page]
      @update = "users"
    elsif params[:everyone_feed_page]
      @update = "everyoneFeeds"
    elsif params[:friends_feed_page]
      @update = "friendsFeeds"
    end

    if @update.nil? || @update == "users" || @update == "friendsFeeds"
      @users = current_user.friendships
      .joins(:followee)
      .order("users.leaderboard_points desc, users.username asc")
      .map { |f| f.followee unless f.followee_id.nil?}
      .paginate(:per_page => 15, :page => params[:user_page])
    end
    if @update == "friendsFeeds"
      userIds = (@users.empty?) ? "NULL" : userIds = @users.map(&:id).join(",")
      @feeds = DataPoint.joins(:user)
      .order("uploaded_at desc")
      .where("users.id IN ("+userIds+")")
      .paginate(:per_page => 10, :page => params[:friends_feed_page])

    end
    if @update == "everyoneFeeds"
      @feeds = DataPoint.includes(:user)
      .order("uploaded_at desc")
      .paginate(:per_page => 10, :page => params[:everyone_feed_page])

    end




    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json
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

end


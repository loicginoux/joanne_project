class FriendshipsController < ApplicationController
  before_filter :require_login
  cache_sweeper :friendship_sweeper
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

    if @update.nil? || @update == "users"
      puts "update users"
      @users = current_user.friendships
      .joins(:followee)
      .order("users.leaderboard_points desc, users.username asc")
      .map { |f| f.followee unless f.followee_id.nil?}
      .paginate(:per_page => 15, :page => params[:user_page])
    end
    if @update == "friendsFeeds"
      puts "update friendsFeeds"
      userIds = current_user.friendships.select(:followee_id).map(&:followee_id).join(",")
      @feeds = DataPoint.includes(:user)
      .includes(:comments)
      .where("users.id IN (#{userIds})")
      .where("uploaded_at < ?", current_user.now())
      .order("uploaded_at desc")
      .paginate(:per_page => 10, :page => params[:friends_feed_page])
    end
    if @update == "everyoneFeeds"
      puts "update everyoneFeeds"
      @feeds = DataPoint.includes(:user)
      .includes(:comments)
      .where("uploaded_at < ?", current_user.now())
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
    # create friendship record
    @friendship = current_user.friendships.build(:followee_id => params[:followee])

    # get followee user record
    followee = User.select(:username).find(params[:followee])
    redirect = (params[:redirect_to]) ? params[:redirect_to] : user_path(:username=> followee.username)
    if @friendship.save
      flash[:notice] = "You're now following #{followee.username.capitalize}. You'll see what #{followee.username.capitalize} is eating under the #{ActionController::Base.helpers.link_to 'Feed page', feed_path()}.".html_safe
      redirect_to redirect
    else
      flash[:notice] = "Unable to add friend."
      redirect_to redirect
    end
  end


  # DELETE /friendships/1
  # DELETE /friendships/1.json
  def destroy
    @friendship = Friendship.find(params[:id])
    @friendship.destroy
    redirect = (params[:redirect_to]) ? params[:redirect_to] : users_path
    respond_to do |format|
      format.html { redirect_to redirect }
      format.json { head :no_content }
    end
  end

end


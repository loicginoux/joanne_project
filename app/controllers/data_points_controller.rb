class DataPointsController < ApplicationController
  before_filter :check_for_cancel, :only => [:create, :update]
  
  def index
    if(params.has_key?(:start_date) && params.has_key?(:end_date)) && params.has_key?(:user_id)
      startDate = Time.zone.parse(params[:start_date]).utc
      endDate = Time.zone.parse(params[:end_date]).utc
      @data_points = DataPoint.where(
        :user_id => params[:user_id],
        :uploaded_at => startDate..endDate
      )
      .order("uploaded_at ASC")
      .find(:all,	
        :select => 'data_points.*, count(comments.id) as nbComments, (SELECT COUNT(*) FROM likes where likes.data_point_id = data_points.id) AS nbLikes',	
        :joins => 'LEFT OUTER JOIN comments on comments.data_point_id = data_points.id LEFT OUTER JOIN likes on likes.data_point_id = data_points.id',	
        :group => ['data_points.id', 'data_points.calories'])
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js {  }
      format.json { render json: @data_points }
    end
  end

  def show
     @data_point = DataPoint.find(params[:id])
     respond_to do |format|
         format.html # show.html.erb
         format.json { render :json => @data_point }
     end
   end
   
  # GET /data_points/new
  # GET /data_points/new.json
  def new    
    @data_point = DataPoint.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @data_point }
    end
  end

  # GET /data_points/1/edit
  def edit
    @data_point = DataPoint.find(params[:id])
  end

  # POST /data_points
  # POST /data_points.json
  def create
    @data_point = DataPoint.new(params[:data_point])
    @data_point.user_id = current_user.id
    @data_point.uploaded_at = DateTime.now
    
    respond_to do |format|
      if @data_point.save
        # publish to facebook
        if current_user.canPublishOnFacebook?
          current_user.fb_publish(@data_point)
          notice = 'Data point was successfully created and shared on Facebook.'
        else
          notice = 'Data point was successfully created.'
        end
        format.html { redirect_to user_path(:username => current_user), notice: notice }
        format.json { render json: @data_point }
      else
        logger.info @data_point.errors.inspect
        format.html { render action: "new" }
        format.json { render json: @data_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /data_points/1
  # PUT /data_points/1.json
  def update
    @data_point = DataPoint.find(params[:id])
    # if there is no photo in parameter, we remove it to not create an empty photo
    if (params[:data_point].has_key?(:photo) && params[:data_point][:photo].blank?)
      params[:data_point].delete(:photo)
    end
    if params[:data_point].has_key?(:uploaded_at)
        # to not take into account timezone
        params[:data_point][:uploaded_at] = Time.zone.parse(params[:data_point][:uploaded_at]).utc
    end
  
    
    respond_to do |format|
      if @data_point.update_attributes(params[:data_point])
        format.html { redirect_to @data_point, notice: 'Data point was successfully updated.' }
        format.json { render json: @data_point }
      else
        format.html { render action: "edit" }
        format.json { render json: @data_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_points/1
  # DELETE /data_points/1.json
  def destroy
    @data_point = DataPoint.find(params[:id])
    @data_point.destroy

    respond_to do |format|
      format.html { redirect_to data_points_url }
      format.json { head :no_content }
    end
  end
  
  def check_for_cancel
    unless params[:cancel].blank?
      redirect_to user_path(:username => current_user)
    end
  end
end

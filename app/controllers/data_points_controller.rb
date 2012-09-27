class DataPointsController < ApplicationController
  before_filter :check_for_cancel, :only => [:create, :update]
  before_filter :require_login, :except => [:create]
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  def index
    if(params.has_key?(:start_date) && params.has_key?(:end_date)) && params.has_key?(:user_id)
      startDate = Time.zone.parse(params[:start_date]).utc
      endDate = Time.zone.parse(params[:end_date]).utc
      @data_points = DataPoint.where(
        :user_id => params[:user_id],
        :uploaded_at => startDate..endDate
      )
      .order("uploaded_at ASC")                
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js {  }
      format.json { render json: @data_points.to_json(:include => [:likes]) }
    end
  end

  def show
     # @data_point = DataPoint.includes(:comments => :us).where("comments.data_point_id", params[:id]).find(params[:id])
     @data_point = DataPoint.includes(:comments => :user).find(params[:id])
     respond_to do |format|
        format.html # show.html.erb
        format.js {  }
        format.json { render :json => @data_point  }
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
    Rails.logger.debug ">>>>>>>>>>>>>>>>>"
    Rails.logger.debug params.inspect
    if !params[:data_point].nil?
      user = current_user
      # This is data coming from forms  
      @data_point = DataPoint.new(params[:data_point])
      @data_point.user_id = user.id
      @data_point.uploaded_at = DateTime.now
    else
      # This is data coming from mailgun 
        
      user = User.find_by_email(params["sender"].downcase)
      if params["Subject"].to_i.to_s == params["Subject"] && user
        @data_point = DataPoint.new
        @data_point.user_id = user.id
        @data_point.calories = params["Subject"]
        @data_point.uploaded_at = DateTime.now
        @data_point.photo = params["attachment-1"]  
      end
    end
    Rails.logger.debug ">>>>>>>>>>>>>>>>>"
    Rails.logger.debug @data_point.inspect
    respond_to do |format|
      if @data_point.save
        # publish to facebook
        if user.canPublishOnFacebook?
          user.fb_publish(@data_point)
          notice = 'Data point was successfully created and shared on Facebook.'
        else
          notice = 'Data point was successfully created.'
        end
        format.html { redirect_to user_path(:username => user), notice: notice }
        format.json { render json: @data_point }
      else
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
    Rails.logger.debug params[:data_point][:uploaded_at]
    if params[:data_point].has_key?(:uploaded_at)
        # to not take into account timezone
        params[:data_point][:uploaded_at] = Time.zone.parse(params[:data_point][:uploaded_at]).utc
    end
    Rails.logger.debug params[:data_point][:uploaded_at]  
    
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
      format.html { redirect_to user_path(:username => current_user) }
      format.json { head :no_content }
    end
  end
  
  def check_for_cancel
    unless params[:cancel].blank?
      redirect_to user_path(:username => current_user)
    end
  end
end

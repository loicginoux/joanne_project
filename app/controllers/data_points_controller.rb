class DataPointsController < ApplicationController
  before_filter :check_for_cancel, :only => [:create, :update]
  
  def index
    if(params.has_key?(:start_date) && params.has_key?(:end_date))
      startDate = Time.zone.parse(params[:start_date]).utc
      endDate = Time.zone.parse(params[:end_date]).utc
      @data_points = DataPoint.where(
        :user_id => current_user.id,
        :uploaded_at => startDate..endDate
      ).order("uploaded_at ASC")
    else
      @data_points = DataPoint.all
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data_points }
    end
  end

  def show
     @data_point = DataPoint.find(params[:id])
     respond_to do |format|
         format.html # show.html.erb
         format.json { render :json => @user }
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
        format.html { redirect_to user_path(:username => current_user), notice: 'Data point was successfully created.' }
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
    if (params[:data_point].has_key?(:photo) && params[:data_point][:photo].blank?)
      params[:data_point].delete(:photo)
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

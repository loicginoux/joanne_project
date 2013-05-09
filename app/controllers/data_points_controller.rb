class DataPointsController < ApplicationController
  before_filter :check_for_cancel, :only => [:create, :update]
  before_filter :require_login, :except => [:create]
  skip_before_filter :verify_authenticity_token, :only => [:create]

  helper_method :get_graphic_points

  cache_sweeper :data_point_sweeper

  def index
    if(params.has_key?(:start_date) && params.has_key?(:end_date)) && params.has_key?(:user_id)
      # startDate = Time.zone.parse(params[:start_date])
      @startDate = DateTime.parse(params[:start_date])
      # endDate = Time.zone.parse(params[:end_date])
      @endDate = DateTime.parse(params[:end_date])

      @data_points = getDataPoints(@startDate, @endDate, params[:user_id] )

      @graphicDatas = {}

      if params.has_key?(:previousDates) && params[:previousDates].has_key?(:start_date) && params[:previousDates].has_key?(:end_date)
        start_prev_date = DateTime.parse(params[:previousDates][:start_date])
        end_prev_date = DateTime.parse(params[:previousDates][:end_date])
        previous_data_points = getDataPoints(start_prev_date, end_prev_date, params[:user_id] )
        @graphicDatas[:previous_period] = getGraphicPoints(previous_data_points, start_prev_date, end_prev_date)
      end

      @graphicDatas[:current_period] = getGraphicPoints(@data_points, @startDate, @endDate)

    end
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def show
    @data_point = DataPoint.includes(:comments => :user).find(params[:id])
    @user = @data_point.user
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
    if params[:data_point].nil?
      DataPoint.createFromMailgun(params)
      # always return 200
      render :text => ""
    else
      @user = current_user
      if params[:data_point][:id]
        @data_point = DataPoint.duplicate(params[:data_point][:id],params[:data_point][:uploaded_at] )
      else
        @data_point = DataPoint.new(params[:data_point])
        @data_point.user_id = @user.id
        @data_point.uploaded_at = Time.zone.now
        puts ">>>>>>>>>>>>> created photo from form"
      end

      if @data_point && @data_point.save
        puts "data point after saved: #{@data_point.inspect}"
        # publish to facebook
        if @user.canPublishOnFacebook?
          @user.fb_publish(@data_point)
        end

        # set content type even if it's json because f... IE doesn't recognized json and prompt
        # download window when returning json
        render :json => @data_point, :content_type => 'text/plain'
      else
        puts "data point not saved, errors: #{@data_point.errors.inspect}"
        render :json => @data_point.errors
      end
    end
  end

  # PUT /data_points/1
  # PUT /data_points/1.json
  def update
    puts ">>>>>>>>>>>>> updated photo"
    puts params[:data_point].inspect
    @data_point = DataPoint.find(params[:id])
    # if there is no photo in parameter, we remove it to not create an empty photo
    if (params[:data_point].has_key?(:photo) && params[:data_point][:photo].blank?)
      params[:data_point].delete(:photo)
    end

    @data_point.editor_id = current_user.id
    # if params[:data_point]["uploaded_at"]
    #   puts "uploaded at in params: #{params[:data_point]['uploaded_at']}"
    #   params[:data_point]["uploaded_at"] = Time.zone.parse(params[:data_point]["uploaded_at"])
    #   puts "uploaded at parsed: #{params[:data_point]['uploaded_at']}"
    # end
    # puts "user: #{@data_point.user.username}"
    # puts "time.now: #{Time.now}"
    # puts "time.zone: #{Time.zone}"
    # puts "time.zone.now: #{Time.zone.now}"
    respond_to do |format|
      if @data_point.update_attributes(params[:data_point])
        puts "data point after saved: #{@data_point.inspect}"
        format.html { redirect_to @data_point, notice: 'Data point was successfully updated.' }
        format.json { render json: @data_point }
      else
        format.html { render action: "edit" }
        format.json { render json: @data_point.errors }
      end
    end
  end

  # DELETE /data_points/1
  # DELETE /data_points/1.json
  def destroy
    @data_point = DataPoint.find(params[:id])

    @data_point.photo.destroy unless @data_point.photo_file_size.nil?
    @data_point.destroy

    respond_to do |format|
      format.html { redirect_to user_path(:username => current_user) }
      format.json { render :json => { :message => "Success" } }
    end
  end

  # GET /data_points/fileInputForm/(:id)
  def getFileUploadForm
    if params[:id]
      @id = params[:id]
      render :partial => "data_points/edit/fileInputForm" , :layout => false
    else
      render :partial => "data_points/create/fileInputForm" , :layout => false
    end
  end

  def check_for_cancel
    unless params[:cancel].blank?
      redirect_to user_path(:username => current_user)
    end
  end

end

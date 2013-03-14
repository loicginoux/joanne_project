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
      @period = params[:period]

      if @period == "week"
        weekNb = @startDate.strftime("%U")
        @data_points = Rails.cache.fetch("/user/#{params[:user_id]}/data_points/#{@period}/#{weekNb}") do
          DataPoint.where(:user_id => params[:user_id],:uploaded_at => @startDate..@endDate).order("uploaded_at ASC").group_by(&:group_by_criteria)
        end
        @graphicDatas = Rails.cache.fetch("/user/#{params[:user_id]}/data_points/#{@period}/#{weekNb}/graphicPoints") do
          getGraphicPoints(@data_points, @startDate, @endDate, @period)
        end
      elsif @period == "month"
        monthNb = @startDate.strftime("%m")
        @data_points = Rails.cache.fetch("/user/#{params[:user_id]}/data_points/#{@period}/#{monthNb}") do
          DataPoint.where(:user_id => params[:user_id],:uploaded_at => @startDate..@endDate).order("uploaded_at ASC").group_by(&:group_by_criteria)
        end
        @graphicDatas = Rails.cache.fetch("/user/#{params[:user_id]}/data_points/#{@period}/#{monthNb}/graphicPoints") do
          getGraphicPoints(@data_points, @startDate, @endDate, @period)
        end
      elsif @period == "day"
        @data_points = DataPoint
          .where(:user_id => params[:user_id],:uploaded_at => @startDate..@endDate)
          .order("uploaded_at ASC")
          .group_by(&:group_by_criteria)
        @graphicDatas = getGraphicPoints(@data_points, @startDate, @endDate, @period)
      end
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
    fromMailgun = false
    # This is data coming from mailgun
    if params[:data_point].nil?
      fromMailgun = true
      user = User.find_by_email(params["sender"].downcase)
      if params["attachment-1"] && user
        Time.zone = user.timezone
        @data_point = DataPoint.new
        @data_point.user_id = user.id
        # calories in subject
        if params["Subject"]
          match = (params["Subject"]).match(/(\d)+/)
          if match && match[0]
            @data_point.calories = match[0]
          else
            @data_point.calories = 0
          end
        else
          @data_point.calories = 0
        end
        # description of photo is in mail body
        if params["stripped-text"]
          match = (params["stripped-text"]).match(/"(.*?)"/)
          @data_point.description = params["stripped-text"].match(/"(.*?)"/)[1]  if (match && match[1])
        end

        # date of photo
        if params["Date"]
          @data_point.uploaded_at = params["Date"]
        else
          @data_point.uploaded_at = Time.zone.now
        end

        @data_point.photo = params["attachment-1"]
        puts ">>>>>>>>>>>>> created photo from mailgun"
      else
        # no attachment or no user
        UserMailer.image_upload_not_working(params["sender"].downcase, params["attachment-1"])
      end
    # This is data coming from forms
    else
      @user = current_user
      if params[:data_point][:id]
        @data_point = DataPoint.find(params[:data_point][:id]).duplicate(params[:data_point][:uploaded_at])
      else
        @data_point = DataPoint.new(params[:data_point])
        @data_point.user_id = @user.id
        @data_point.uploaded_at = Time.zone.now
        puts ">>>>>>>>>>>>> created photo from form"
      end
    end

    if @data_point && @data_point.save
      puts "data point after saved: #{@data_point.inspect}"
      # publish to facebook
      if @user.canPublishOnFacebook?
        @user.fb_publish(@data_point)
      end
      if fromMailgun
        # mailgun expect a 200 response, so we need to send him something
        render :text => ""
      elsif !fromMailgun && current_user
        # set content type even if it's json because f... IE doesn't recognized json and prompt
        # download window when returning json
        render :json => @data_point, :content_type => 'text/plain'
      end

    elsif !fromMailgun
      puts "data point not saved, errors: #{@data_point.errors.inspect}"
      render :json => @data_point.errors

    elsif fromMailgun
      # mailgun expect a 200 response, so we need to send him something
      render :text => ""
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

  private

  def getGraphicPoints(data_points, startDate, endDate, period)
    puts data_points
    calories = []
    if @period == "week" || period == "month"
      arr = Array(@startDate..@endDate)
      for date in arr
        data_points = @data_points[date.strftime("%F")]
        dayCalorie = 0
        if !data_points.nil?
          data_points.each do |photo|
            dayCalorie += photo.calories
          end
        end
        if period == "month"
          dayCalorie = [(date.beginning_of_day().strftime("%s").to_i) * 1000, dayCalorie]
        end
        calories.push(dayCalorie)
      end
    else
      # period = "day"
      data_points = @data_points[startDate.strftime("%F")]
      if !data_points.nil?
        calories = data_points.map(&:calories)
      end
    end
    return calories
  end

end

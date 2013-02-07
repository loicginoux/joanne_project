class LikesController < ApplicationController
  before_filter :require_login

  # # GET /likes
  # # GET /likes.json
  # def index
  #   if (params.has_key?(:user_id) && params.has_key?(:data_point_id))
  #     @likes = Like.where(
  #       :user_id => params[:user_id],
  #       :data_point_id => params[:data_point_id]
  #     )

  #   end
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.json { render json: @likes }
  #   end
  # end

  # # GET /likes/1
  # # GET /likes/1.json
  # def show
  #   @like = Like.find(params[:id])

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @like }
  #   end
  # end

  # GET /likes/new
  # GET /likes/new.json
  def new
    @like = Like.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @like }
    end
  end

  # # GET /likes/1/edit
  # def edit
  #   @like = Like.find(params[:id])
  # end

  # POST /likes
  # POST /likes.json
  def create
    @like = Like.new(params[:like])

    respond_to do |format|
      if @like.save
        format.html { redirect_to @like, notice: 'Like was successfully created.' }
        format.json { render json: @like, status: :created, location: @like }
      else
        format.html { render action: "new" }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  # # PUT /likes/1
  # # PUT /likes/1.json
  # def update
  #   @like = Like.find(params[:id])

  #   respond_to do |format|
  #     if @like.update_attributes(params[:like])
  #       format.html { redirect_to @like, notice: 'Like was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: "edit" }
  #       format.json { render json: @like.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /likes/1
  # DELETE /likes/1.json
  def destroy
    @like = Like.find(params[:id])
    if current_user.is(@like.user)
      @like.destroy
      render :json => {:status => "deleted", :id => params[:id]}, :status => :ok
    else
      render :json => {:status => "permission error", :id => params[:id]}, :status => :ok
    end
  end
end

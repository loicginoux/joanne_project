
class CommentsController < ApplicationController
  before_filter :require_login

  # GET /comments
  # GET /comments.json
  def index
    @comments = nil
    if params[:data_point_id]
      @comments = Comment.includes(:user).where(:data_point_id => params[:data_point_id]).order("created_at ASC")
    end
    respond_to do |format|
      format.js {  }
      format.json { render json: @comments }
    end
  end


  # # GET /comments/1
  # # GET /comments/1.json
  # def show
  #   @comment = Comment.find(params[:id])

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @comment }
  #   end
  # end

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end

  # # GET /comments/1/edit
  # def edit
  #   @comment = Comment.find(params[:id])
  # end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(params[:comment])
    respond_to do |format|
      if @comment.save
        format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
        format.json { render json: @comment}
      else
        format.html { render action: "new" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # # PUT /comments/1
  # # PUT /comments/1.json
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment = Comment.find(params[:id])
    if current_user.is(@comment.user)
      @comment.destroy
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end

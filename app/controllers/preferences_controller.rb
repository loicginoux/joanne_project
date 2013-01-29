class PreferencesController < ApplicationController
  # # GET /comments/1
  # # GET /comments/1.json
  # def show
  #   @comment = Comment.find(params[:id])

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @comment }
  #   end
  # end

  # def new
  #   @preference = Preference.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @preference }
  #   end
  # end

  # # GET /comments/1/edit
  # def edit
  #   @comment = Comment.find(params[:id])
  # end

  # POST /comments
  # POST /comments.json
  # def create
  #   @comment = Comment.new(params[:comment])
  #   respond_to do |format|
  #     if @comment.save
  #       format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
  #       format.json { render json: @comment}
  #     else
  #       format.html { render action: "new" }
  #       format.json { render json: @comment.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PUT /comments/1
  # # PUT /comments/1.json
  def update
    @preference = Preference.find(params[:id])
		@user = current_user
    @url = edit_user_path(:username=> current_user.username)
    if @preference.update_attributes(params[:preference])
    	redirect_to edit_user_path(:username=> @user.username), notice: 'Successfully updated profile.'
    else
      redirect_to edit_user_path(:username=> @user.username), notice: "You can't do that...try again."
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  # def destroy
  #   @comment = Comment.find(params[:id])
  #   if current_user.is(@comment.user)
  #     @comment.destroy
  #   end

  #   respond_to do |format|
  #     format.json { head :no_content }
  #   end
  # end

end

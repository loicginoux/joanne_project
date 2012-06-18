class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :mailer_set_url_options
  helper_method :current_user

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to root_url, :alert => exception.message
  end
  
  #authentification
  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  def mailer_set_url_options
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end 

end

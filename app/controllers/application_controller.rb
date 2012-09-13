class ApplicationController < ActionController::Base  
  protect_from_forgery
  
  before_filter :mailer_set_url_options
  before_filter :set_timezone  
  helper_method :current_user
  
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to root_url, :alert => exception.message
  end
  
  rescue_from FbGraph::Exception, :with => :fb_graph_exception

  def fb_graph_exception(e)
    flash[:error] = {
      :title => e.class,
      :message => e.message
    }
    redirect_to static_path('home')
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
  
  def set_timezone  
    # current_user.time_zone #=> 'Central Time (US & Canada)'  
    if current_user
      Time.zone = current_user.timezone || 'Central Time (US & Canada)'  
    end
  end
  

  def require_login
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_url
    end
  end
  
  def store_location
    session[:return_to] = request.env['REQUEST_URI']
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end

class UserSession < Authlogic::Session::Base
	single_access_allowed_request_types :any
	find_by_login_method :find_by_username_or_email
end

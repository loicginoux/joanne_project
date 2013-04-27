Cucumber::Rails::World.class_eval do

  def login_for_user( user )
	  visit(login_path)
	  fill_in "user_session_username", with: user.username
		fill_in "user_session_password", with: user.password
	  click_button "Log in"
	end

	def send_password_recovery_email(user)
		visit lost_password_path()
		fill_in "email", with: user.email
		click_button "Reset my password"
	end

	def login_with_oauth(service = :facebook)
    visit "/auth/#{service}"
  end

end
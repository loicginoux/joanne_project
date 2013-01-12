foodrubix.user_sessions.new = foodrubix.user_sessions.create = () ->
	$("#new_user_session").submit(()->
		validated = true
		$(".alert, .alert .username, .alert .password").addClass("hide")
		unless $(".username input").val()
			validated = false
			$(".alert").removeClass("hide").find(".username").removeClass("hide")
		unless $(".password input").val()
			validated = false
			$(".alert").removeClass("hide").find(".password").removeClass("hide")
		return validated;
	)

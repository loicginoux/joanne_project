foodrubix.users.new = () ->
	$("#user_email").focus(()->
		$(".important_email").removeClass("hide")
	)
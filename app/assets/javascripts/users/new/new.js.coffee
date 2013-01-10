foodrubix.users.new = foodrubix.users.create = () ->
	$("#user_email").focus(()->
		$(".important_email").removeClass("hide")
	)

	# detect time zone automatically and fill up the timezone user field
	$("#user_timezone").val(jstz.determine().name())
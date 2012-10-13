window.foodrubix =
	common: {}
	users: {}
	data_points: {}
	user_sessions: {}

foodrubix.common.init = () ->
	# fadeOutAlert()

fadeOutAlert = ()->
	setTimeout(() ->
		$(".alert-info").fadeOut(300, () -> $(this).remove())
	, 5000)


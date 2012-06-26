window.foodrubix = {}
foodrubix.common = {}
foodrubix.users = {}
foodrubix.data_points = {}

foodrubix.common.init = () ->
	fadeOutAlert()
	
	
	
fadeOutAlert = ()->
	setTimeout(() ->
		$(".alert-info").fadeOut(300, () -> $(this).remove())
	, 5000)
	
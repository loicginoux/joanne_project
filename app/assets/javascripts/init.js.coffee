window.foodrubix =

	common: {}
	users: {}
	data_points: {}
	user_sessions: {}

foodrubix.common.init = () ->
	ua = navigator.userAgent.toLowerCase()
	gon.browser = ""
	if (ua.indexOf('safari')!=-1)
		if (ua.indexOf('chrome')  > -1)
			gon.browser = "chrome"
		else
			gon.browser = "safari"


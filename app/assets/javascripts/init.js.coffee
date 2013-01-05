window.foodrubix =

	common: {}
	users: {}
	data_points: {}
	user_sessions: {}

foodrubix.common.init = () ->
	ua = navigator.userAgent.toLowerCase()
	if typeof gon == "undefined"
		window.gon = {}
	gon.browser = ""
	ie = /MSIE ([0-9]{1,}[\.0-9]{0,})/.exec(ua)
	if (ua.indexOf('safari')!=-1)
		if (ua.indexOf('chrome')  > -1)
			gon.browser = "chrome"
		else
			gon.browser = "safari"
	else if (ie)
		gon.browser = "IE"
		gon.browserVersion = ie[1]




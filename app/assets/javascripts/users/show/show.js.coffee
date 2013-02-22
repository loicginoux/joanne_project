foodrubix.users.show = () ->
	new foodrubix.PhotoCalendar({el: $("#photoCalendar")})
	manageLoginTooltip()



manageLoginTooltip = () ->
	if gon.isCurrentUserDashboard && !gon.last_login_at && gon.daily_calories_limit == 0 && !UTIL.readCookie("DoNotDsplayCaloriesTip")
		UTIL.setCookie("DoNotDsplayCaloriesTip", true, 30)
		$("#hi_current_user").popover({
			placement:"bottom",
			trigger: "manual",
			title: "TIP!"
			content: "Visit the Settings menu to enter your goal (5 pts.), set your daily calorie limit (5 pts.) and enable Facebook sharing (10 pts.). Do it now before you forget!"
		})
		$('#hi_current_user').popover('show')
		$(".popover.bottom").css("left", "-=100")
		$(".popover.bottom .arrow").css("left", "80%")
		$("#hi_current_user").click(()->
			$(this).popover("hide")
		)
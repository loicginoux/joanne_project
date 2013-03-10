foodrubix.users.show = () ->
	new foodrubix.PhotoCalendar({el: $("#photoCalendar")})
	manageLoginTooltip()





manageLoginTooltip = () ->
	if gon.isCurrentUserDashboard && !gon.last_login_at && gon.daily_calories_limit == 0 && !UTIL.readCookie("DoNotDsplayCaloriesTip")
		UTIL.setCookie("DoNotDsplayCaloriesTip", true, 30)
		target = $(".hi_current_user").not(".hide")
		target.popover({
			placement:"bottom",
			trigger: "manual",
			title: "TIP!",
			content: "Visit the Settings menu to enter your goal (5 pts.), set your daily calorie limit (5 pts.), add a profile photo (5 pts.), and enable Facebook sharing (10 pts.). Do it now before you forget!"
		})
		target.popover('show')
		$(".popover.bottom").css("left", "-=100").css("z-index", "2000")
		$(".popover.bottom .arrow").css("left", "80%")
		target.click(()->
			$(this).popover("hide")
		)
		$(".popover.in").click(()->
			$(this).popover("hide")
		)
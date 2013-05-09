foodrubix.users.show = () ->
	new foodrubix.PhotoCalendarManager()
	manageLoginTooltip()

manageLoginTooltip = () ->
	if gon.isCurrentUserDashboard && !gon.last_login_at && gon.daily_calories_limit == 0 && !UTIL.readCookie("DoNotDsplayCaloriesTip")
		UTIL.setCookie("DoNotDsplayCaloriesTip", true, 30)
		target = $(".hi_current_user").not(".hide")
		target.popover({
			placement:"bottom",
			trigger: "manual",
			html: 'true',
			title : '<span class="text-info"><strong>TIP!</strong></span><button type="button" id="close" class="close" onclick="$(&quot;.hi_current_user&quot;).popover(&quot;hide&quot;);">&times;</button>',
			content: "<p>Visit the <a href='/"+gon.current_user_username.toLowerCase()+"/edit'>Settings menu</a> to enter your goal (5 pts.), set your daily calorie limit (5 pts.), add a profile photo (5 pts.), and enable Facebook sharing (10 pts.). Do it now before you forget!</p>"
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
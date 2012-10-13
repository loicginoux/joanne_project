foodrubix.users.show = () ->
	photoCalendar: new foodrubix.PhotoCalendar({el: $("#photoCalendar")})
	manageLoginTooltip()



manageLoginTooltip = () ->
	console.log gon.isCurrentUserDashboard, gon.last_login_at
	if gon.isCurrentUserDashboard && !gon.last_login_at && gon.daily_calories_limit == 0
		console.log "display"
		$("#hi_current_user").popover({
			placement:"bottom",
			trigger: "manual",
			title: "TIP"
			content: "Visit the Settings menu to set up your daily calorie goal and enable Facebook sharing. Do it now before you forget!"
		})
		$('#hi_current_user').popover('show')
		$(".popover.bottom").css("left", "-=100")
		$(".popover.bottom .arrow").css("left", "80%")
		$("#hi_current_user").click(()->
			$(this).popover("hide")
		)
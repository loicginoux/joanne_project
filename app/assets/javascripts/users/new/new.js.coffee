foodrubix.users.new = foodrubix.users.create = () ->
	$("#user_email").focus(()->
		$(".important_email").removeClass("hide")
	)

	# detect time zone automatically and fill up the timezone user field
	$("#user_timezone").val(jstz.determine().name())

	coachingIntensityController = new foodrubix.RadioBoxController({
		el: $(".coaching_intensity"),
		input: $("#user_preference_attributes_coaching_intensity")
	})

	caracterCounterController = new foodrubix.CaracterCounterController({
		el: $(".eating-habits"),
		input: $("#user_preference_attributes_eating_habits"),
		counter: $(".caraterCounter"),
		limit: 130,
		submitButton: $(".form-actions .btn-primary")
	})
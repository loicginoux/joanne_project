foodrubix.users.edit  = foodrubix.users.update = () ->
	tabController = new foodrubix.SettingsTabController({el: $(".row")})
	pictureController = new foodrubix.SettingsPictureController({el: $("#picture")})
	coachingIntensityController = new foodrubix.RadioBoxController({
		el: $(".coaching_intensity"),
		input: $("#preference_coaching_intensity")
	})
	caracterCounterController = new foodrubix.CaracterCounterController({
		el: $(".eating-habits"),
		input: $("#preference_eating_habits"),
		counter: $(".caraterCounter"),
		limit: 130,
		submitButton: $(".form-actions .btn-primary")
	})

	window.UTIL.loadAsynchScript({
		src: "http://www.wolframalpha.com/widget/widget.jsp?id=3f0b9e714dc05b05aad90cae08d25e3b&theme=orange&output=lightbox"
		scriptId: "WolframAlphaScript3f0b9e714dc05b05aad90cae08d25e3b",
		parent: "#wolframScript"
	})



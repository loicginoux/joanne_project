foodrubix.users.edit  = foodrubix.users.update = () ->
	tabController = new foodrubix.SettingsTabController({el: $(".row")})
	pictureController = new foodrubix.SettingsPictureController({el: $("#picture")})
	coachingIntensityController = new foodrubix.RadioBoxController({
		el: $(".coaching_intensity"),
		input: $("#preference_coaching_intensity")
	})



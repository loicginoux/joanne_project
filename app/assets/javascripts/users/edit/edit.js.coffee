foodrubix.users.edit  = foodrubix.users.update = () ->
	tabController = new foodrubix.SettingsTabController({el: $(".row")})
	pictureController = new foodrubix.SettingsPictureController({el: $("#picture")})



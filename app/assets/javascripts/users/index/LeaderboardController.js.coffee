class foodrubix.LeaderboardController extends Spine.Controller
	events:
		"change select" : "changeDiet"
	elements:
		"select" : "select"
		".users" : "users"
		".loading" : "loadingEl"

	changeDiet:	(e) ->
		@log e
		that = @
		data = {}
		data.update = @list
		data.diet = e.target.value
		data[@pageParamName] = 1
		@users.empty()
		@loadingEl.removeClass("hide")
		$.ajax({
			type: 'GET',
			url: 'users.js',
			data: data,
			success: () ->
				that.loadingEl.addClass("hide")
		})
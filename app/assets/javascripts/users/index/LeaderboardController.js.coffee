class foodrubix.LeaderboardController extends Spine.Controller
	events:
		"change select" : "changeDiet"
	elements:
		"select" : "select"
		".users" : "users"

	changeDiet:	(e) ->
		@log e
		that = @
		data = {}
		data.update = @list
		data.diet = e.target.value
		data[@pageParamName] = 1
		@users.empty()
		# window.UTIL.load(@users, @pageParamName, true)
		$.ajax({
			type: 'GET',
			url: 'users.js',
			data: data,
			success: () ->
				# window.UTIL.load(that.users, that.pageParamName, false)
		})
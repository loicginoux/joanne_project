foodrubix.users.index = () ->
	$(".winner-ribbon").tooltip()
	totalLeaderboardController = new foodrubix.LeaderboardController({
		el: $(".total_leaderboard"),
		pageParamName: "total_leaderboard_page"
	})
	totalLeaderboardController = new foodrubix.LeaderboardController({
		el: $(".leaderboard"),
		pageParamName: "leaderboard_page"
	})


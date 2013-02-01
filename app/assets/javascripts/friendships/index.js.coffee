foodrubix.friendships.index = () ->
	feedsManager = new foodrubix.feeds({
		el:$('.feeds')
	})
	return {
		feedsManager:feedsManager
	}
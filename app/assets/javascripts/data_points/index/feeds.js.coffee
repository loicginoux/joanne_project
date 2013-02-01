class foodrubix.feeds extends Spine.Controller
	elements:
		".feed": "feeds"
		"#show_more_feeds_link": "moreBtn"

	constructor: () ->
		super
		@controllers = []
		@loading = false
		that = @
		@feeds.each((i,e) ->
			that.controllers.push(new foodrubix.dataPointViewManager({
				el:e
			}))
		)
		that = this
		window.setInterval((() -> that.checkScrollBottom())	, 250)
		window.Spine.bind 'feeds:loaded', () ->
			that.stopLoading()

	checkScrollBottom:()->
		# check that we arrive near the end of the page
		if (($(document).height() - $(window).scrollTop() - $(window).height()) < 500)
			# check that we haven't yet made the call for more feed
			# and that the show more hidden button is here (in the contrary, it means there is no more feed to load)
			if !@loading && @moreBtn.length
				console.log("start loading")
				UTIL.load($('.feedLoading'), "feedL", true)
				@moreBtn.click()
				@loading = true

	stopLoading:() ->
		@loading = false
		console.log("stop loading")
		UTIL.load($('.feedLoading'), "feedL", false)
class foodrubix.feeds extends Spine.Controller
	elements:
		".feed": "feeds"
		"h3": "title"
		".show_more_btns": "showMoreContainer"
		".feedList": "feedList"

	events:
		"click .btn.listToggler": "toggleList"

	constructor: () ->
		super
		@controllers = []
		@loading = false
		that = @

		feed = if (UTIL.readCookie("feedList")) then UTIL.readCookie("feedList") else "everyone"
		$(".btn.listToggler."+feed).click()

		that = this
		window.setInterval((() -> that.checkScrollBottom())	, 250)
		window.Spine.bind 'feeds:loaded', () ->
			that.stopLoading()

	checkScrollBottom:()->
		# check that we arrive near the end of the page
		if (($(document).height() - $(window).scrollTop() - $(window).height()) < 500)
			# check that we haven't yet made the call for more feed
			# and that the show more hidden button is here (in the contrary, it means there is no more feed to load)
			moreBtn = $("#show_more_feeds_link")
			if !@loading && moreBtn.length
				UTIL.load($('.feedLoading'), "feedL", true)
				console.log("start loading")
				moreBtn.click()
				@loading = true

	stopLoading:() ->
		that = @
		@loading = false
		console.log("stop loading")
		UTIL.load($('.feedLoading'), "feedL", false)
		$(".feed").each((i,e) ->
			that.controllers.push(new foodrubix.dataPointViewManager({
				el:$(e)
			}))
		)


	toggleList:(e) ->
		btn = $(e.target)
		unless btn.hasClass('active')
			@showMoreContainer.empty()
			# @feedList.empty()
			for ctrl in @controllers
				ctrl.release()
			@controllers = []
			if btn.hasClass("everyone")
				UTIL.load($('.feedLoading'), "feedL", true)
				@loading = true
				@title.html("What everyone else is eating")
				@fetchFeeds("everyoneFeeds")
				UTIL.setCookie("feedList", "everyone", 30)

			else
				UTIL.load($('.feedLoading'), "feedL", true)
				@loading = true
				@title.html("What people I'm following are eating")
				@fetchFeeds("friendsFeeds")
				UTIL.setCookie("feedList", "friends", 30)

	fetchFeeds:(list) ->
		$.ajax({
			type: 'GET',
			url: '/friendships.js',
			data: {
				update : list
			}
		})
		# dataType: 'json',
		# success: onSuccessFetch.bind @




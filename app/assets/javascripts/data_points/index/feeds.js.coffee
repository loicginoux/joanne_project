class foodrubix.feeds extends Spine.Controller
	elements:
		".feed": "feeds"

	constructor: () ->
		super
		@controllers = []
		that = @
		@feeds.each((i,e) ->
			that.controllers.push(new foodrubix.dataPointViewManager({
				el:e
			}))
		)
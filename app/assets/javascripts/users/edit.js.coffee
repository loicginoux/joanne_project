foodrubix.users.edit = () ->
	tabController = new TabController({el: $(".row")})


class TabController extends Spine.Controller
	events:
		"click li": "changeTab"

	elements:
		".nav li": "pills"
		".content": "contents"

	constructor: ()->
		super		
		
	changeTab: (e) =>
		this.pills.removeClass("active")
		this.contents.addClass("hide")
		target = $(e.currentTarget).addClass("active")
		content_id = target.attr "data-content"
		this.contents.filter("#"+content_id).removeClass("hide")
		
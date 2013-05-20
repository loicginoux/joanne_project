class foodrubix.SettingsTabController extends Spine.Controller
	events:
		"click li": "changeTab"

	elements:
		".nav li": "pills"
		".content": "contents"

	constructor: ()->
		super
		path = if Spine.Route.getPath() then Spine.Route.getPath() else "profile"
		this.pills.filter("[data-content="+path+"]").click()

	changeTab: (e) =>
		this.pills.removeClass("active")
		this.contents.addClass("hide")
		target = $(e.currentTarget).addClass("active")
		content_id = target.attr "data-content"
		this.contents.filter("#"+content_id).removeClass("hide")

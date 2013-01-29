class foodrubix.RadioBoxController extends Spine.Controller
	events:
		"click .btn" : "switchOption"
	elements:
		".btn-group" : "btnGroup"
		".btn-group .btn" : "buttons"
		".helps" : "helps"
		".help-inline" : "inlineHelps"


	constructor: ()->
		super
		@input.val("low") unless @input.val()
		id =  @input.val()
		@btnGroup.find("[data-id='"+id+"']").addClass "active"
		@helps.find("."+id).removeClass("hide")

	switchOption:	(e) ->
		@inlineHelps.addClass("hide")
		id = $(e.target).attr("data-id")
		@helps.find("."+id).removeClass("hide")
		@input.val(id)
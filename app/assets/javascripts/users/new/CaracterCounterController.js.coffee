class foodrubix.CaracterCounterController extends Spine.Controller
	constructor: ()->
		super
		@updateCounter()
		@input.bind "keyup", @updateCounter.bind(@)

	updateCounter:	(e) ->
		length =  @input.val().length
		rest = @limit - length
		@counter.html(rest)
		if rest < 0
			@el.addClass("error")
			@submitButton.prop("disabled", "disabled")
		else
			@el.removeClass("error")
			@submitButton.prop("disabled", false)
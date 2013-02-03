class foodrubix.CommentListController extends Spine.Controller
	events:
		"click .startEdit": "startEditing"
		"click .delete": "delete"
		"keydown textarea": "onkeyDown"


	getId:(e)->
		$(e.target).parents(".comment").attr("data-id")

	getEl:(e)->
		$(e.target).parents(".comment")

	startEditing: (e)->
		commentEl = @getEl e
		commentEl.find(".edit").removeClass("hide")
		commentEl.find(".view").addClass("hide")
		textarea = commentEl.find("textarea")
		textarea.focus()
		@moveCaretToEnd(textarea[0]);
		# Work around Chromes little problem
		that = this
		window.setTimeout((()-> that.moveCaretToEnd(textarea[0])), 10)

	moveCaretToEnd: (el) ->
		if (typeof el.selectionStart == "number")
			el.selectionStart = el.selectionEnd = el.value.length
		else if (typeof el.createTextRange != "undefined")
			el.focus()
			range = el.createTextRange()
			range.collapse(false)
			range.select()


	stopEditing:(e)->
		id = @getId(e)
		commentEl = @getEl e
		textareaVal = commentEl.find("textarea").val()
		$.ajax({
			type: "PUT",
			url: '/comments/'+id+'.json'
			data:
				comment:
					text: textareaVal
		})
		commentEl.find(".commentText").html(textareaVal)
		@cancelEditing(e)

	onkeyDown:(e)->
		if e.keyCode == 27 #echap
			@cancelEditing(e)
		if e.keyCode == 13 #enter
			@stopEditing(e)
			e.preventDefault()


	cancelEditing:(e)->
		commentEl = @getEl e
		commentEl.find(".view").removeClass("hide")
		commentEl.find(".edit").addClass("hide")

	delete: (e)->
		id = @getId(e)
		$.ajax({
			type: "delete",
			url: '/comments/'+id+'.json'
		})
		@getEl(e).remove()
		if @master
			@master.updateNumberComments(-1)

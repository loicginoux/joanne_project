class foodrubix.dataPointViewManager extends Spine.Controller

	elements:
		".btn-comment":               "btnComment"
		".btn-delete":                "deleteBtn"
		".btn-edit":                  "editBtn"
		".btn-like":                  "btnLike"
		'.btn-save':                  "saveBtn"
		".btn-upload":                "uploadBtn"
		".btn-cancel":                "cancelBtn"
		".btn-confirm-delete":        "btnConfirmDelete"
		".newComment":                "inputComment"
		".control-group.comment":     "divTextarea"
		".nbLikes":                   "nbLikesHTML"
		".nbComments":                "nbCommentsHTML"
		".comments":                  "comments"
		".commentText":               "commentTexts"
		".viewMode":                  "viewElements"
		".editMode":                  "editElements"
		".editable_img_container img":"img"
		# ".data_point_photo":          "fileInput"
		".progress":                  "progress"
		".progress .bar":             'bar'
		"#data_point_calories":       "calories"
		".datePicker":                "datePicker"
		'#data_point_uploaded_at':    "uploaded_at"
		".timePicker":                "timePicker"
		".control-group":             "controlGroups"
		".help-inline":               "inlineHelps"
		".alert-delete":              "deleteMessage"
		"#data_point_description":    "descrVal"

	events:
		"click .btn-like":    "like"
		"click .btn-comment": "comment"
		"keydown textarea.newComment":  "onEnter"
		"click .btn-edit":    "startEditing"
		"click .btn-cancel":  "switchMode"

	constructor: ()->
		super
		@ALLOWED_FILE_EXTENSIONS = [
			"jpg",
			"JPG",
			"png",
			"PNG",
			"jpeg",
			"JPEG",
			"gif",
			"GIF",
			"TIF",
			"tif"
		]

	init: () ->
		@id = @el.find(".info").attr('data-id')
		@userId = $("body").attr("data-user")
		@nbLikes = parseInt(@nbLikesHTML.text()) || 0
		@nbComments = parseInt(@nbCommentsHTML.text()) || 0
		$(".likers").tooltip()
		@replaceCommentsLinks()
		commentController = new foodrubix.CommentListController({
			el: @el.find(".comments"),
			master: @
			})


	refreshComments: () =>
		$.ajax({
			type: "GET"
			url: '/comments'
			dataType: 'script'
			data:
				data_point_id: @id
		})


	replaceCommentsLinks:()->
		UTIL.replaceURLWithHTMLLinks(@commentTexts)


	onEnter: (e) =>
		if e.keyCode == 13  #enter
			@comment()
			e.preventDefault()

	comment: () =>
		if @btnComment.attr("disabled")
			return
		@el.find(".control-group.comment").removeClass('error')
		@el.find('.help-inline.comment').addClass('hide')
		if @divTextarea.hasClass("hide")
			@divTextarea.removeClass("hide")
			@divTextarea.find("textarea").focus()
		else
			text = @inputComment.blur().val()
			if text != ""
				@btnComment.button('loading').attr("disabled", true)
				data =
					user_id: @userId
					text: text
					data_point_id: @id
				$.ajax({
					type: "POST"
					url: '/comments.json'
					success: @onSuccessComment.bind @
					dataType: 'json'
					data:
						comment : data
				})
			else
				# display error message
				@el.find(".control-group.comment").addClass('error')
				@el.find('.help-inline.comment').removeClass('hide')


	onSuccessComment: (data, textStatus, jqXHR) =>
		@btnComment.button('reset').attr("disabled", false).removeClass("disabled")
		@inputComment.val("")
		@divTextarea.addClass("hide")
		@updateNumberComments(1)
		@refreshComments()

	updateNumberComments: (nbCom) ->
		@nbComments = @nbComments+nbCom
		@nbCommentsHTML.html(@nbComments)
		@updateMasterInfo("comments")

	updateMasterInfo: (which, id) =>
		if @master
			  # body...
			if which == "comments"
				@master.el.find("#image_"+@id+ " span.nbComments").html(@nbComments)
			else if which == "like"
				if !id then console.log("no like id provided for master")
				@master.el
					.find("#image_"+@id+ " span.nbLikes")
					.html(@nbLikes)
					.parent(".label-info")
					.addClass("liked")
					.attr("like-id", id)
					.find("i")
					.addClass("icon-thumbs-down")
					.removeClass("icon-thumbs-up")
			else if which == "unlike"
				@master.el
					.find("#image_"+@id+ " span.nbLikes")
					.html(@nbLikes)
					.parent(".label-info")
					.removeClass("liked")
					.attr("like-id", '')
					.find("i")
					.removeClass("icon-thumbs-down")
					.addClass("icon-thumbs-up")

	like: () =>
		if @btnLike.attr("disabled")
			return

		@btnLike.attr("disabled", true)
			.addClass("disabled")

		if @btnLike.attr("data-action") == "Like"
			$.ajax({
				type: "POST"
				url: '/likes.json'
				success: @onSuccessLike
				dataType: 'json'
				data:
					like :
						user_id: @userId
						data_point_id: @id
			})
		else
			likeId = @btnLike.attr("data-like-id")

			$.ajax({
				type: "DELETE"
				url: '/likes/'+likeId+'.json'
				success: @onSuccessUnlike
				dataType: 'json'
			})







	onSuccessLike: (data, textStatus, jqXHR) =>
		@btnLike.attr("data-like-id", data.id)
		@nbLikes = @nbLikes+1
		@nbLikesHTML.html(@nbLikes)
		@updateMasterInfo("like", data.id)
		@changeLikeState("Unlike")

	onSuccessUnlike: (data, textStatus, jqXHR) =>
		@nbLikes = @nbLikes - 1
		@nbLikesHTML.html(@nbLikes)
		@updateMasterInfo("unlike")
		@changeLikeState("Like")

	changeLikeState: (text) =>
		@btnLike.attr("data-action", text)
			.attr("disabled", false)
			.removeClass("disabled")
			.find("span").html(" "+ text)
			.end()
			.find("i")
				.toggleClass("icon-thumbs-up")
				.toggleClass("icon-thumbs-down")

	removeDataPoint: (e) =>
		@deleteBtn.button('loading')
		dataType = if @master then "json" else "html"
		$.ajax({
		          type: "DELETE",
		          url: '/data_points/'+@id+'.json',
		          dataType: dataType,
		          success: @onSuccessDelete
		})

	onSuccessDelete:(e) ->
		if @master
			@master.onSuccessAjax(e)
		else
			window.location.href = "/"+@el.attr("data-username")

	onSuccessUpdate:(e) ->
		if @master
			@master.onSuccessAjax(e)
		else
			window.location.reload()

	startEditing: () ->
		@switchMode()
		@fileInput = @el.find("#ifu_"+@id).contents().find("#fileInput_"+@id)
		now = new Date()
		day = now.toString("MM-dd-yyyy")
		time = now.toString("hh:mm tt")
		@datePicker.datepicker()
		@timePicker.timePicker({show24Hours: false})
		@uploadBtn.unbind("click").click @changePhoto
		@fileInput.unbind("change").change @onChangePhoto
		@saveBtn.unbind("click").click @validateDataPointData
		@deleteBtn.unbind("click").click @removeDataPoint
		@btnConfirmDelete.unbind("click").click @showConfirmDeleteBox



	switchMode:()->
		@viewElements.toggleClass("hide")
		@editElements.toggleClass("hide")
		@comments.toggleClass("hide")

	changePhoto: (e) =>
		@fileInput.click()
		e.stopPropagation()
		e.preventDefault()
		return false


	onChangePhoto: (e) =>
		input = e.target
		that = this
		fileName = @fileInput.val()
		extension = fileName.substring(fileName.lastIndexOf('.') + 1);
		if input.files && input.files[0] && typeof FileReader != "undefined" && _.contains(@ALLOWED_FILE_EXTENSIONS, extension )
			reader = new FileReader()
			reader.onload = (e) ->
				that.img.attr('src', e.target.result).parent().css("height", "auto");
			reader.readAsDataURL(input.files[0]);

	validateDataPointData: (e) =>
		validated = true

		if !parseInt(@id)
			throw "no id for update modal box"

		#remove all previous error
		@controlGroups.removeClass('error')
		@inlineHelps.not(".fileExtension").addClass('hide')

		# validate calories
		calories = @calories.val()
		if isNaN(parseInt(calories)) || parseInt(calories) < 0
			validated = false
			@el.find(".control-group.calories").addClass('error')
			@el.find('.help-inline.calories').removeClass('hide')

		# validate date
		input = @datePicker.find('input')
		dateVal = input.val()
		ISODate =  Date.parse(dateVal,"M-d-yyyy")
		unless ISODate
			validated = false
			@el.find(".control-group.date").addClass('error')
			@el.find('.help-inline.date').removeClass('hide')

		# validate time
		timePickerId = "#timePicker_"+@id
		date = $.timePicker(timePickerId).getTime()
		unless date
			validated = false
			@el.find(".control-group.time").addClass('error')
			@el.find('.help-inline.time').removeClass('hide')

		# validate photo
		fileName = @fileInput.val()
		if fileName
			extension = fileName.substring(fileName.lastIndexOf('.') + 1);
			if !_.contains(@ALLOWED_FILE_EXTENSIONS, extension )
				validated = false
				@el.find(".control-group.file").addClass('error')
				# @el.find('.help-inline.fileExtension').removeClass('hide')


		ISODate.set(
			hour:date.getHours(),
			minute:date.getMinutes()
		)

		if validated
			@updateDataPoint(e, {
				id:@id,
				calories: parseInt(calories),
				uploaded_at: UTIL.prepareForServer(ISODate),
				description: @descrVal.val()
			})


	# data should have id, calories, uploaded_at
	updateDataPoint: (e, data) =>
		that = @
		@saveBtn.button('loading')

		# 	update data
		onSuccessUpdate = (response, textStatus, jqXHR) ->
			$.ajax({
				type: "PUT",
				url: '/data_points/'+data.id+'.json',
				success: that.onSuccessUpdate.bind(that)
				data:
					data_point : data
			})

		beforeSend = () ->
			@progress.removeClass('hide')
			@uploadBtn.addClass('hide')
			@bar.width('0%')

		uploadProgress = (event, position, total, percentComplete) ->
			percentVal = percentComplete + '%';
			@bar.width(percentVal)

		# update photo first
		if @fileInput.val()
			form = $("#ifu_"+@id).contents().find("form")
			form.attr('method', 'PUT').ajaxSubmit(
				dataType:"json",
				complete: (jqXHR, textStatus)->
					console.log("complete ajax submit")
					console.log(jqXHR, jqXHR.status, textStatus)
					# success
					# status == 0 is for our friend IE
					if jqXHR.status == 200 || jqXHR.status == 0
						onSuccessUpdate(JSON.parse(jqXHR.responseText), textStatus, jqXHR)
				beforeSend: beforeSend.bind @
				uploadProgress: uploadProgress.bind @
			)
		else
			onSuccessUpdate()

	showConfirmDeleteBox: () =>
		@deleteMessage.removeClass('hide')

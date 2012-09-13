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
		".input-comment":             "inputComment"
		".control-group.comment":     "divTextarea"
		".nbLikes":                   "nbLikesHTML"
		".nbComments":                "nbCommentsHTML"
		".viewMode":                  "viewElements"
		".editMode":                  "editElements"
		".editable_img_container img":"img"
		".data_point_photo":          "fileInput"
		".progress":                  "progress"
		".progress .bar":             'bar'
		"#data_point_calories":       "calories"
		".datePicker":                "datePicker"
		'#data_point_uploaded_at':    "uploaded_at"
		".timePicker":                "timePicker"
		".control-group":             "controlGroups"
		".help-inline":               "inlineHelps"
		".alert-delete":              "deleteMessage"

	events:
		"click .btn-like":    "like"
		"click .btn-comment": "comment"
		"keypress textarea":  "onEnter"
		"click .btn-edit":    "startEditing"
		"click .btn-cancel":  "switchMode"

		

	constructor: ()->
		super
	
	init: () ->
		@id = @el.find(".info").attr('data-id')
		@userId = $("body").attr("data-user")
		@nbLikes = parseInt(@nbLikesHTML.text())
		@nbComments = parseInt(@nbCommentsHTML.text())
		
	refreshLike: () =>
		$.ajax({
			type: "GET"
			url: '/likes'
			dataType: 'json'
			data: 
				data_point_id: @id
				user_id: @userId
			success: @ongetLikeState.bind @
		})
	
	ongetLikeState: (data) =>
		if data.length
			@likeId = data[0].id
			@changeLikeState("Liked")
			

	refreshComments: () =>
		$.ajax({
			type: "GET"
			url: '/comments'	
			dataType: 'script'
			data: 
				data_point_id: @id
		})
		
	onEnter: (e) =>
		
		if e.keyCode == 13  #enter
			@comment()
			return false
		
	comment: () =>
		if @btnComment.attr("disabled")
			return
		if @divTextarea.hasClass("hide")
			@divTextarea.removeClass("hide")
			@divTextarea.find("textarea").focus()
		else
			text = @inputComment.val()
			if text != ""
				@el.find(".control-group.comment").removeClass('error')
				@el.find('.help-inline.comment').addClass('hide')
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
		@nbComments = @nbComments+1
		@nbCommentsHTML.html(@nbComments)
		@updateMasterInfo("comments")
		@refreshComments()
		
	updateMasterInfo: (which) =>
		if @master
			  # body...
			if which == "comments"
				@master.el.find("#image_"+@id+ " span.nbComments").html(@nbComments)
			else if which == "likes"
				@master.el.find("#image_"+@id+ " span.nbLikes").html(@nbLikes)
	
	like: () =>
		if @btnLike.attr("disabled")
			return

		@btnLike.attr("disabled", true)
			.addClass("disabled")
			
		if @btnLike.attr("data-action") == "Like"
			console.log("like, @id, @user_id:", @id, @userId)
			
			
			$.ajax({
				type: "POST"
				url: '/likes.json'
				success: @onSuccessLike.bind @
				dataType: 'json'
				data: 
					like : 
						user_id: @userId
						data_point_id: @id
			})
		else
			likeId = @btnLike.attr("data-like-id")
			console.log("unlike,", likeId)
			
			$.ajax({
				type: "DELETE"
				url: '/likes/'+likeId+'.json'
				success: @onSuccessUnlike.bind @
				dataType: 'json'
			})
		
		

			

	
	
	onSuccessLike: (data, textStatus, jqXHR) =>
		console.log("likeid created", data.id)
		
		@btnLike.attr("data-like-id", data.id)
		@nbLikes = @nbLikes+1
		@nbLikesHTML.html(@nbLikes)
		@updateMasterInfo("likes")
		@changeLikeState("Unlike")
	
	onSuccessUnlike: (data, textStatus, jqXHR) =>
		@nbLikes = @nbLikes - 1
		@nbLikesHTML.html(@nbLikes)
		@updateMasterInfo("likes")
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
		          success: @onSuccess.bind @
		})	

	onSuccess:(e) ->
		if @master
			@master.onSuccessAjax(e)
		else
			window.location.href = "/"+@el.attr("data-username")
	
	startEditing: () ->
		@switchMode()
		@datePicker.datepicker()
		@timePicker.timePicker({show24Hours: false})
		@uploadBtn.click @changePhoto
		@fileInput.change @onChangePhoto
		@saveBtn.click @validateDataPointData
		@deleteBtn.click @removeDataPoint
		@btnConfirmDelete.click @showConfirmDeleteBox
		@cancelBtn.click @clean
		@isNewUploadBox = (@el.attr('id') == "new_upload")
		if @isNewUploadBox
			@clearNewUpload()
	
	
	switchMode:()->
		@viewElements.toggleClass("hide")		
		@editElements.toggleClass("hide")
	
	changePhoto: (e) =>
		@fileInput.click()
		e.stopPropagation()
		e.preventDefault()
		return false


	onChangePhoto: (e) =>
		input = e.target
		if input.files && input.files[0]
			reader = new FileReader()
			reader.onload = (e) ->
				$(input).parent().find("img").attr('src', e.target.result).parent().css("height", "auto");
			reader.readAsDataURL(input.files[0]);

	validateDataPointData: (e) =>
		validated = true

		if !parseInt(@id) && !@isNewUploadBox
			throw "no id for update modal box"

		#remove all previous error 
		@controlGroups.removeClass('error')
		@inlineHelps.addClass('hide')		

		# validate calories
		calories = @calories.val()
		unless parseInt calories
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
		timePickerId = if @isNewUploadBox then "#timePicker" else "#timePicker_"+@id
		date = $.timePicker(timePickerId).getTime() 
		unless date 
			validated = false
			@el.find(".control-group.time").addClass('error')
			@el.find('.help-inline.time').removeClass('hide')

		# validate photo
		if @isNewUploadBox
			unless @fileInput.val()
				validated = false
				@el.find(".control-group.file").addClass('error')
				@el.find('.help-inline.file').removeClass('hide')

		ISODate.set(
			hour:date.getHours(),
			minute:date.getMinutes()
		)

		if validated
			@updateDataPoint(e, {
				id:@id
				calories: calories
				uploaded_at: ISODate
			})


	# data should have id, calories, uploaded_at
	updateDataPoint: (e, data) =>
		@saveBtn.button('loading')	

		# 	update data 
		onSuccessUpdate = (response, textStatus, jqXHR) ->
			if !data.id #in case this is a new upload we need to precise the id from the first ajax request
				data.id = response.id
			console.log("data:",data)
			
			$.ajax({
				type: "PUT",
				url: '/data_points/'+data.id+'.json',
				data: 
					data_point : data,
					dataType: 'json'
				success: @onSuccess.bind @
			})

		beforeSend = () ->
			@progress.removeClass('hide')
			@uploadBtn.addClass('hide')
			@bar.width('0%')

		uploadProgress = (event, position, total, percentComplete) ->
			percentVal = percentComplete + '%';
			@bar.width(percentVal)

		# update photo first
		form = if @isNewUploadBox then $("#uploadForm") else $("#uploadForm_"+data.id);
		form.ajaxSubmit(
			dataType:"json"
			success: onSuccessUpdate.bind @
			beforeSend: beforeSend.bind @
			uploadProgress: uploadProgress.bind @
		)

	showConfirmDeleteBox: () =>
		@deleteMessage.removeClass('hide')
			
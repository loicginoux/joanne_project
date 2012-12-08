class foodrubix.DataPointEditModal	extends Spine.Controller

	elements:
		"#photos":                 "photos"
		"img":                     "img"
		".data_point_photo":       "fileInput"
		".progress":               "progress"
		".progress .bar":          'bar'
		"#data_point_calories":    "calories"
		".datePicker":             "datePicker"
		'#data_point_uploaded_at': "uploaded_at"
		".timePicker":             "timePicker"
		'.btn-save':               "saveBtn"
		".control-group":          "controlGroups"
		".help-inline":            "inlineHelps"
		".btn-upload":             "uploadBtn"
		".btn-confirm-delete":     "btnConfirmDelete"
		".btn-delete":             "deleteBtn"
		".btn-cancel":             "cancelBtn"
		".alert-delete":           "deleteMessage"
		"#data_point_description": "descrVal"

	constructor: ()->
		super
		@id = @el.attr('data-id')

	initialize: () ->
		@datePicker.datepicker()
		@timePicker.timePicker({show24Hours: false})
		console.log(gon.browser)
		if gon.browser == "safari"
			@uploadBtn.addClass("hide")
			@fileInput.removeClass("hide")
		else
			@uploadBtn.click @changePhoto
		@fileInput.change @onChangePhoto
		@saveBtn.click @validateDataPointData
		@deleteBtn.click @removeDataPoint
		@btnConfirmDelete.click @showConfirmDeleteBox
		@cancelBtn.click @clean
		@isNewUploadBox = (@el.attr('id') == "new_upload")
		if @isNewUploadBox
			@clearNewUpload()


	clearNewUpload: () ->
		@img.attr('src','').parent().height("200px")
		@fileInput.val('')
		@progress.addClass('hide')
		if gon.browser == "safari"
			@fileInput.removeClass('hide')
		else
			@uploadBtn.removeClass('hide')
		@bar.width('0%')
		@calories.val('')
		# now = new Date()
		# @uploaded_at.val(now.toString("MM-dd-yyyy"))
		# @timePicker.val(now.toString('hh:mm tt'))
		@descrVal.val("")
		@saveBtn.button('reset')
		@controlGroups.removeClass('error')
		@inlineHelps.addClass('hide')

	clean: () =>
		if @isNewUploadBox
			@clearNewUpload()
		@uploadBtn.unbind "click"
		@fileInput.unbind "change"
		@saveBtn.unbind "click"
		@deleteBtn.unbind "click"
		@btnConfirmDelete.unbind "click"
		@cancelBtn.unbind "click"

	changePhoto: (e) =>
		@fileInput.click()
		e.stopPropagation()
		e.preventDefault()
		return false


	onChangePhoto: (e) =>
		input = e.target
		if input.files && input.files[0] && typeof FileReader != "undefined"
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
				id:@id,
				calories: calories,
				uploaded_at: ISODate.toISOString(),
				description:  @descrVal.val()
			})


	# data should have id, calories, uploaded_at
	updateDataPoint: (e, data) =>
		@saveBtn.button('loading')

		# 	update data
		onSuccessUpdate = (response, textStatus, jqXHR) ->
			if !data.id #in case this is a new upload we need to precise the id from the first ajax request
				data.id = response.id
			$.ajax({
				type: "PUT",
				url: '/data_points/'+data.id+'.json',
				data:
					data_point : data,
					success: @master.onSuccessAjax.bind @master
					complete: (jqXHR)->
						console.log("complete ajax")
						console.log(arguments)
			})

		beforeSend = () ->
			@progress.removeClass('hide')
			@uploadBtn.addClass('hide')
			@fileInput.addClass('hide')
			@bar.width('0%')

		uploadProgress = (event, position, total, percentComplete) ->
			percentVal = percentComplete + '%';
			@bar.width(percentVal)

		# update photo first
		form = if @isNewUploadBox then $("#uploadForm") else $("#uploadForm_"+data.id);
		# first we need to send the file because jquery ajax can't do it
		# on the success function we then update the attributes
		form.ajaxSubmit(
			dataType:"json",
			success: onSuccessUpdate.bind @
			complete: (jqXHR, textStatus)->
						console.log("complete ajax submit")
						console.log(jqXHR, textStatus)
			beforeSend: beforeSend.bind @
			uploadProgress: uploadProgress.bind @
		)

	showConfirmDeleteBox: () =>
		@deleteMessage.removeClass('hide')

	removeDataPoint: (e) =>
		@deleteBtn.button('loading')

		$.ajax({
		          type: "DELETE",
		          url: '/data_points/'+@id+'.json',
		          dataType: 'json',
		          success: @master.onSuccessAjax.bind @master
		})


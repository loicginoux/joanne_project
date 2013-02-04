class foodrubix.PhotoCalendar extends Spine.Controller

	events:
		"click .period": "changeView"
		"click .prev": "goToPrev"
		"click .next": "goToNext"
		"click .today": "goToToday"
		# "hover .image": "onHoverImage"
		"click .image": "onImageClick"
		"click .overlay .like": "like"
		"hover .overlay .label": "changeLabelColor"

		"shown .modal.uploadPhoto": "initUploadModal"
		"hidden .modal.uploadPhoto": "cleanUploadModal"

		"shown .modal.viewPhoto": "fetchViewModal"
		"hidden .modal.viewPhoto": "cleanViewModal"
		"modalRendered .viewPhoto": "initViewModal"

	elements:
		"#photos": "photos"
		"#graphicContainer": "graphic"
		".period": "periodButtons"
		".emptyState": "emptyState"

	constructor: ()->
		super
		UTIL.load($('#photos'), "photos", true)
		@period = "week"
		@date = Date.today()
		@userId = @el.attr("data-user")
		@period = if (UTIL.readCookie("period")) then UTIL.readCookie("period") else "week"
		$(".period."+@period).click()
		@uploadModal = new foodrubix.DataPointUploadModal({
			el:$('.modal.uploadPhoto')
			master: @
		})

	# refresh the photos on the page
	refresh: () ->
		UTIL.load($('#photos'), "photos", true)
		@getDataPoints(@onSuccessFetch)

	#get start date and end date from a period and a date
	# period is "day" or "week" or "month"
	# date is a Date object
	getDates: () ->
		@startDate = @date.clone()
		@endDate = @date.clone()
		if @period == "day"
			@endDate.set({hour:23, minute:59, second:59})
		else if @period == "week"
			@startDate.last().sunday() unless @date.is().sunday()
			@startDate.clearTime()
			@endDate.next().saturday() unless @date.is().saturday()
			@endDate.set({hour:23, minute:59, second:59})
		else if @period == "month"
			@startDate.moveToFirstDayOfMonth().clearTime()
			@endDate.moveToLastDayOfMonth().set({hour:23, minute:59, second:59})

	#make the ajax call to get the data points
	# for current user and between the @startDate and @endDate
	getDataPoints: (onSuccessFetch) ->
		$.ajax({
			type: 'GET',
			url: '/data_points.json',
			data: {
				start_date : UTIL.prepareForServer(@startDate) ,
				end_date : UTIL.prepareForServer(@endDate),
				user_id: @userId
			},
			dataType: 'json',
			success: onSuccessFetch.bind @
		})

	# change the views from month, week or day view
	changeView: (e) ->
		btn = $(e.target)
		unless btn.hasClass('active')
			UTIL.load($('#photos'), "photos", true)
			@graphic.empty()
			@periodButtons.removeClass 'active'
			btn.addClass 'active'
			@period = btn.attr("data-period")
			@date = Date.today()
			@getDates()
			@getDataPoints(@onSuccessFetch)
			UTIL.setCookie("period", @period, 30)


	goTo:(multiple)->
		UTIL.load($('#photos'), "photos", true)
		@graphic.empty()

		switch @period
			when "day" then @date.add(1*multiple).days()
			when "week" then @date.add(7*multiple).days()
			when "month" then @date.add(30*multiple).days()

		@getDates()
		@getDataPoints(@onSuccessFetch)

	# go to the previous month/week/day depending on current displayed period
	goToPrev: () -> @goTo(-1)

	# go to the next month/week/day depending on current displayed period
	goToNext: () -> @goTo(1)


	# display the right period which includes the day of today
	goToToday: () ->
		UTIL.load($('#photos'), "photos", true)
		@graphic.empty()
		@date = Date.today()
		@getDates()
		@getDataPoints(@onSuccessFetch)

	#function to run on success of the ajax call to get data points
	#data are data points
	onSuccessFetch: (data) ->
		#display loading gif
		UTIL.load($('#photos'), "photos", false)
		if !data.length && Date.today().between(@startDate, @endDate) && gon.isCurrentUserDashboard
			@emptyState.removeClass("hide")
		else
			@emptyState.addClass("hide")
			dataSorted = @groupDataByDay(data)
			if @period == "week"
				dataSorted = @createWeekDays(dataSorted)
			else if @period == "month"
				dataSorted = @createMonthDays(dataSorted)
			@displayPhotos(dataSorted)
			graphic = new foodrubix.graphic(dataSorted, @period, @date)

			@el.delegate(".image", "hover", @onHoverImage.bind(@))

	# create the json data for displaying the month view
	# {month:[
	# 	{week_number:1,
	# 	week_data:[
	# 		{day}
	# 	]}
	# ]}
	createMonthDays:(data) ->
		month = []
		week = {week_data:[]}
		week_number = 1
		date = @startDate.clone()
		#add the first days of the first week that belongs to previous month
		until date.is().sunday()
			date.add(-1).days()
			week.week_data.unshift({
				date: date,
				date_drop: date.toString("MM-dd-yyyy"),
				day_date: date.toString('d'),
				data_points: [],
				other_month:true
			})
		#fill the month days
		date = @startDate.clone()
		endDate = @endDate.clone()
		endDate.add(1).seconds()
		until date.equals(endDate)

			#when we arrive at the end of the week we start another array
			if date.is().sunday()
				week.week_number = week_number
				week_number += 1
				month.push(week)
				week = {week_data:[]}

			data_points = []
			for point in data
				if point.date.equals(date)
					data_points = point.data_points
			clone = date.clone()
			week.week_data.push({
				date: clone,
				date_drop: clone.toString("MM-dd-yyyy"),
				day_date: clone.toString('d'),
				data_points: data_points,
				current_month:true
			})
			#add one day
			date.add(1).days()

		#add the last days of the last week that belongs to next month
		until date.is().sunday()
			week.week_data.push({
				date: date,
				date_drop: date.toString("MM-dd-yyyy"),
				day_date: date.toString('d'),
				data_points: [],
				other_month:true
			})
			date.add(1).days()

		month.push(week)
		month

	#create an array of 7 items with empty days if there is no photo uploaded
	createWeekDays: (data) ->
		newData = []
		for num in [0..6]
			date = @startDate.clone()
			date.add(num).days()
			data_points = []
			first = if num == 0 then true else false
			for point in data
				if point.date.equals(date)
					data_points = point.data_points
			newData.push({
				date: date,
				date_drop: date.toString("MM-dd-yyyy"),
				day_date: date.toString('dddd'),
				data_points: data_points
				first: first
			})
		newData

	# group data by day
	# return data sorted by date
	# [{date: date, data:[]}]
	groupDataByDay: (data) ->
		dataSorted = []
		for point in data
			# date = UTIL.getJsDateFromServer(point.uploaded_at)
			date = Date.parse(point.uploaded_at)
			date.clearTime()
			if dataSorted == []
				dataSorted.push({
					date: date,
					day_date: date.toString('dddd'),
					data_points: [point]
				})
			else
				added = false
				for day in dataSorted
					if date.compareTo(day.date) == 0
						day.data_points.push(point)
						added = true
				if !added
					dataSorted.push({
						date: date,
						day_date: date.toString('dddd'),
						data_points: [point]
					})
		return dataSorted


	#display the photo list
	#data has the form [{date:Date, data_points:[data_point]}]
	displayPhotos: (data) ->
		group = []
		incr = 0
		formatDate = "MMM d"
		$('#photos').empty()
		if @period == "day" or @period == "week"
			for day in data
				for dataPoint in day.data_points
					dataPoint.img_path = dataPoint.id + "/medium.jpg"
					# we remove the timezone part of the date
					# date = UTIL.getJsDateFromServer(dataPoint.uploaded_at)
					date = Date.parse(dataPoint.uploaded_at)
					dataPoint.uploaded_at_readable = date.toString('hh:mm tt')
					dataPoint.uploaded_at_editable = date.toString('MM-dd-yyyy')
					dataPoint.time_uploaded_at = date.toString('hh:mm tt')
					dataPoint.ribbon = false
					dataPoint.ribbon = "Smart Choice" if dataPoint.smart_choice_award
					dataPoint.ribbon = "Hot Photo" if dataPoint.hot_photo_award
					likeId = @userLikeImage( @userId, dataPoint)
					if likeId
						dataPoint.liked = "liked"
						dataPoint.like_class = "icon-thumbs-down"
						dataPoint.like_id = likeId
					else
						dataPoint.liked = ""
						dataPoint.like_class = "icon-thumbs-up"

		else if @period == "month"
			for week in data
				for day in week.week_data
					for dataPoint in day.data_points
						dataPoint.img_path = dataPoint.id + "/medium.jpg"
						# date = UTIL.getJsDateFromServer(dataPoint.uploaded_at)
						date = Date.parse(dataPoint.uploaded_at)
						dataPoint.uploaded_at_readable = date.toString('hh:mm tt')
						dataPoint.uploaded_at_editable = date.toString('MM-dd-yyyy')
						dataPoint.time_uploaded_at = date.toString('hh:mm tt')
						dataPoint.ribbon = false
						dataPoint.ribbon = "Smart Choice" if dataPoint.smart_choice_award
						dataPoint.ribbon = "Hot Photo" if dataPoint.hot_photo_award
						likeId = @userLikeImage( @userId, dataPoint)
						if likeId
							dataPoint.liked = "liked"
							dataPoint.like_class = "icon-thumbs-down"
							dataPoint.like_id = likeId
						else
							dataPoint.liked = ""
							dataPoint.like_class = "icon-thumbs-up"

		if (@period == "day")
			tmpl = $('#day_photos_tmpl').html()
			json = {
				data:data,
				hr_date: @startDate.toString("ddd d MMM yyyy")
			}
		else if (@period == "week")
			tmpl = $('#week_photos_tmpl').html()
			json = {
				data:data,
				startDate: @startDate.toString(formatDate)
				endDate: @endDate.toString(formatDate)
				year: @endDate.toString("yyyy")
			}
		else if (@period == "month")
			tmpl = $('#month_photos_tmpl').html()
			json = {
				data:data,
				month: @startDate.toString("MMMM")
				year: @endDate.toString("yyyy")
			}
		html = Mustache.render(tmpl, json )
		$('#photos').append html
		if gon.isCurrentUserDashboard
			@attachDragAndDrops()

	# when we drag and drop images around, we need to resize the css height of the day/week/month
	unifyHeights: () ->
		fn = (weekSpans)->
			arr = weekSpans.map((i, el) ->
	            return $(el).outerHeight()
	        )
	        max = Math.max.apply(null, arr)
			if (weekSpans.find(".sortableImages").children().length)
				sortableImagesHeight = max-18
			else
				sortableImagesHeight = 20
			weekSpans.find(".sortableImages").css("height",sortableImagesHeight).end().eq(0).parent().css('height', max+10)

		weekSpans = $('.week_view .span1_7')
		# week view
		if weekSpans.length
			fn(weekSpans)
	    # month view
		else
			$(".month_view tbody tr").each((i, el)->
				weekSpans = $(el).find(".span1_7")
				fn(weekSpans)
			)

	# Determines if the passed element is overflowing its bounds,
	# either vertically or horizontally.
	# Will temporarily modify the "overflow" style to detect this
	# if necessary.
	checkOverflow: (el)->
		curOverflow = el.style.overflow
		if ( !curOverflow || curOverflow == "visible" )
			el.style.overflow = "hidden"
		isOverflowing = el.clientWidth < el.scrollWidth  || el.clientHeight < el.scrollHeight
		el.style.overflow = curOverflow
		isOverflowing

	# attach the drag and drop feature to move photos around
	attachDragAndDrops:()->

		$(".span1_7 img").imagesLoaded(@unifyHeights)
		that = @
		# overflow is used when the images overflow the height of the week height
		overflow = false
		# canResize is used to tell to resize the day when went out from
		canResize = false
		# the number of pixel we resise at
		canResizeAt = 0
		placeHolderHeight = 0
		# which element to resize after going out of a connected list
		elemOutResize = ""
		# this is for the copy option
		@ctrlDown = false
		ctrlKey = 17
		cmdKey = 91

		$(".sortableImages").sortable({
			connectWith: ".sortableImages",
			helper: "clone",
			start: (e, ui)-> # when we start drag and drop
				placeHolderHeight = ui.item.height()
				ui.placeholder.height(placeHolderHeight)
				that.sortedItemIndex = ui.item.index()
				that.sortedDayFrom = ui.item.parent()
				ui.item.parent("ul").addClass "hoverActive"
				console.log "that.ctrlDown:", that.ctrlDown
				that.copyItem = false
				if that.ctrlDown
					$(ui.item).show()
					that.copyItem = true
			# out and over are only use in week and month view where we use connected lists
			out: (e, ui)-> # when going out of a connected list
				# that.log "out", $(e.target).parent().index()
				# overflow is set while going over a connected list
				if overflow
					# we could resize here but in some case it doesn't work,
					# so I resize on over
					canResize = true
					# that.log "out of overflow"
					target = $(e.target)
					targetHeight = target.height()
					canResizeAt = targetHeight - placeHolderHeight
					parentTr = target.parent().parent("tr")
					if parentTr.length
						elemOutResize = parentTr.find(".sortableImages")
					else
						elemOutResize = $(".sortableImages")
			over: (e, ui)-> # when going over a connected list
				# that.log "over", $(e.target).parent().index()
				$(".sortableImages").removeClass "hoverActive"
				target = $(e.target)
				target.addClass "hoverActive"
				# the element to resize "elemToResize" depends on the week or month view
				parentTr = target.parent().parent("tr")
				if parentTr.length
						elemToResize = parentTr.find(".sortableImages")
					else
						elemToResize = $(".sortableImages")
				# this is set up on the "out" event
				if canResize
					# we resize the element we go out from
					elemOutResize.height( canResizeAt )
				# if when dragging over the content overflow the height
				# we need to adjust the height of the week
				if that.checkOverflow(e.target)
					overflow = true
					that.log "overflow"
					targetHeight = target.height()
					elemToResize.height(targetHeight + placeHolderHeight )
				else
					overflow = false
				return true
			stop: (e,ui) ->
				that.onDrop(e,ui)
		})

		# if we keep control or command while dragging we copy the photo
		$(document)
		.unbind("keydown.copy")
		.unbind("keyup.copy")
		.bind("keydown.copy", (e)->
			if (e.keyCode == ctrlKey || e.keyCode == cmdKey)
				that.ctrlDown = true
				# if ctrl or cmd is down, this is a copy of photo
				$( ".sortableImages" ).sortable( "option", "helper", "clone" );
    )
    .bind("keyup.copy", (e)->
    	if (e.keyCode == ctrlKey || e.keyCode == cmdKey)
    		that.ctrlDown = false
    		# if ctrl or cmd is up, dragging is to move the photo
    		$( ".sortableImages" ).sortable( "option", "helper", "original" );
    )

	#  called when we drop a photo on day view
	onDrop:(event, ui)->
		that = @
		recipient = $(".hoverActive")
		recipient.removeClass "hoverActive"
		if @sortedItemIndex == ui.item.index() && recipient.is(@sortedDayFrom) then return

		# form the new date
		id = ui.item.attr("data-id") | ui.item.find(".image").attr("data-id")
		nextPhotoTime = ui.item.next().find(".time").text()
		prevPhotoTime = ui.item.prev().find(".time").text()
		recipientDay = if (recipient.parent().attr("data-date")) then Date.parse(recipient.parent().attr("data-date")) else @date

		if nextPhotoTime
			nextPhotoDate = recipientDay.set({
				hour:Date.parse(nextPhotoTime).getHours()
				minute:Date.parse(nextPhotoTime).getMinutes()
			})
			datePhoto = nextPhotoDate.add(-1).minutes()
		else if prevPhotoTime
			prevPhotoDate = recipientDay.set({
				hour:Date.parse(prevPhotoTime).getHours()
				minute:Date.parse(prevPhotoTime).getMinutes()
			})
			datePhoto = prevPhotoDate.add(+1).minutes()
		else
			timeVal = ui.item.find(".time").text()
			time = Date.parse(timeVal, 'hh:mm tt')
			datePhoto = recipientDay.set({
				hour:time.getHours(),
				minute:time.getMinutes()
			})

		if datePhoto
			UTIL.load($('#photos'), "photos", true)
			if @copyItem
				# create new photo
				$.ajax({
					type: "POST",
					url: '/data_points.json',
					success: () ->
						that.onSuccessAjax()
					data:
						data_point : {
							id: id,
							uploaded_at: UTIL.prepareForServer(datePhoto)
						},
						dataType: 'json'
				})
			else
				# update date
				$.ajax({
					type: "PUT",
					url: '/data_points/'+id+'.json',
					success: () ->
						that.onSuccessAjax()
					data:
						data_point : {
							id: id,
							uploaded_at: UTIL.prepareForServer(datePhoto)
						},
						dataType: 'json'
				})

	# return true if the user 'userId' like the 'dataPoint'
	userLikeImage: (userId, dataPoint) ->
		return like.id for like in dataPoint.likes when like.user_id.toString() == userId

	#  when hovering an image
	onHoverImage: (e) ->
		target = $(e.target)
		image = target.parents('.image')
		if !image.length then image = target
		overlay = image.find(".overlay")

		if e.type == "mouseleave"
			overlay.stop().animate({
				bottom: '-44px'
				}, 300)
		else
			overlay.stop().animate({
				bottom: '0px'
				}, 300)


	#  called when we click the upload button and the modal box appears
	initUploadModal: (e) =>
		@activeModal = @uploadModal
		@uploadModal.initialize()

	#  called when we close the upload modal box
	cleanUploadModal: (e) =>
		@uploadModal.clean()

	# loads the view template of a data point
	# called when we click on a photo
	fetchViewModal: (e) =>
		$.ajax({
			type: 'GET',
			url: '/data_points/'+@idImageClicked,
			dataType: 'script'
		})

	#  clear the view modal html when closing the view modal box
	cleanViewModal:()=>
		@activeModal.release()

	# called when the modal box for the view image is rendered
	initViewModal: () ->
		@activeModal = new foodrubix.dataPointViewManager({
		 	el:$('.modal.in .modal-body').children()
		 	master: @
		})

	onImageClick: (e) =>
		@idImageClicked = $(e.target).parents(".image").attr("data-id")


	# when a photo is edited or created, we need to refresh the view to
	# include the new photo
	onSuccessAjax: (data) =>
		$(".modal.in").modal('hide')
		if @activeModal
			if typeof @activeModal.clean == "function"
				@activeModal.clean()
			else
				@activeModal.release()
		UTIL.load($('#photos'), "photos", true)
		@graphic.empty()
		@emptyState.addClass("hide")
		fn = ()->
			@refresh()
		_.delay(fn.bind(@), 1000) #we put a delay to give time to server to update before to refresh


	# like an image
	like:(e)=>
		el = $(e.target)
		label = if el.hasClass("label") then el else el.parent(".label.like")
		id = el.parents(".image").attr("data-id")

		data =
			user_id: @userId
			data_point_id: id

		if !label.hasClass("disabled") && !label.hasClass("liked")
			nbLikes = label.children(".nbLikes").text()
			nbLikes = parseInt(nbLikes)+1
			label
				.addClass("liked")
				.addClass("disabled")
				.children(".nbLikes")
					.html(nbLikes)
				.end().find("i")
					.toggleClass("icon-thumbs-up")
					.toggleClass("icon-thumbs-down")
			$.ajax({
				type: "POST"
				url: '/likes.json'
				success: (data) ->
					label.removeClass("disabled")
					label.attr("like-id", data.id)

				dataType: 'json'
				data:
					like : data
			})

		if !label.hasClass("disabled") && label.hasClass("liked")
			nbLikes = label.children(".nbLikes").text()
			nbLikes = parseInt(nbLikes)-1
			label
				.removeClass("liked")
				.addClass("disabled")
				.children(".nbLikes")
					.html(nbLikes)
				.end().find("i")
					.toggleClass("icon-thumbs-up")
					.toggleClass("icon-thumbs-down")
			$.ajax({
				type: "DELETE"
				url: '/likes/'+label.attr("like-id")+'.json'
				success: () ->
					label.removeClass("disabled")
					label.attr("like-id", "")
				dataType: 'json'
				data:
					like : data
			})
		e.stopPropagation()

	# change the label color when hovering the overlay of the image
	changeLabelColor:(e)=>
		el = $(e.target)
		if el.hasClass("label")
			el
				.toggleClass("label-info")
				.toggleClass("label-important")
		else
			el.parent(".label")
				.toggleClass("label-info")
				.toggleClass("label-important")



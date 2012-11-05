class foodrubix.PhotoCalendar extends Spine.Controller

	events:
		"click .period": "changeView"
		"click .prev": "goToPrev"
		"click .next": "goToNext"
		"click .today": "gotToToday"
		"hover .image": "onHoverImage"
		"click .image": "onImageClick"
		"click .overlay .like": "like"
		"hover .overlay .label": "changeLabelColor"
		"shown .modal.uploadPhoto": "initEditModal"
		"shown .modal.viewPhoto": "fetchViewModal"
		"modalRendered .viewPhoto": "initViewModal"

	elements:
		"#photos": "photos"
		"#graphicContainer": "graphic"
		".period": "periodButtons"

	constructor: ()->
		super
		UTIL.load($('#photos'), "photos", true)
		@period = "week"
		@date = Date.today()
		@userId = @el.attr("data-user")
		@getDates("week", Date.today())
		@getDataPoints(@onSuccessFetch)
		@uploadModal = new foodrubix.DataPointEditModal({
			el:$('.modal.uploadPhoto')
			master: @
		})

	refresh: () ->
		UTIL.load($('#photos'), "photos", true)
		@getDataPoints(@onSuccessFetch)

	#get start date and end date from a period and a date
	# period is "day" or "week" or "month"
	getDates: (period, date) ->
		@startDate = date.clone()
		@endDate = date.clone()
		if @period == "day"
			@endDate.set({hour:23, minute:59, second:59})
		else if @period == "week"
			@startDate.last().sunday() unless date.is().sunday()
			@startDate.clearTime()
			@endDate.next().saturday() unless date.is().saturday()
			@endDate.set({hour:23, minute:59, second:59})
		else if @period == "month"
			@startDate.moveToFirstDayOfMonth().clearTime()
			@endDate.moveToLastDayOfMonth().set({hour:23, minute:59, second:59})

	#make the ajax call to get the data points
	getDataPoints: (onSuccessFetch) ->
		$.ajax({
			type: 'GET',
			url: '/data_points.json',
			data: {
				start_date : @startDate.toISOString() ,
				end_date : @endDate.toISOString(),
				user_id: @userId
			},
			dataType: 'json',
			success: onSuccessFetch.bind @
		})

	changeView: (e) ->
		btn = $(e.target)
		unless btn.hasClass('active')
			UTIL.load($('#photos'), "photos", true)
			@graphic.empty()
			@periodButtons.removeClass 'active'
			btn.addClass 'active'
			@period = btn.attr("data-period")
			@date = Date.today()
			@getDates(@period, @date)
			@getDataPoints(@onSuccessFetch)

	goToPrev: () ->
		UTIL.load($('#photos'), "photos", true)
		@graphic.empty()

		switch @period
			when "day" then @date.add(-1).days()
			when "week" then @date.add(-7).days()
			when "month" then @date.add(-30).days()

		@getDates(@period, @date)
		@getDataPoints(@onSuccessFetch)

	goToNext: () ->
		UTIL.load($('#photos'), "photos", true)
		@graphic.empty()

		switch @period
			when "day" then @date = @date.add(1).days()
			when "week" then @date = @date.add(7).days()
			when "month" then @date = @date.add(30).days()

		@getDates(@period, @date)
		@getDataPoints(@onSuccessFetch)

	gotToToday: () ->
		UTIL.load($('#photos'), "photos", true)
		@graphic.empty()
		@date = Date.today()
		@getDates(@period, @date)
		@getDataPoints(@onSuccessFetch)

	#function to run on success of the ajax call to get data points
	#data are data points
	onSuccessFetch: (data) ->
		#display loading gif
		UTIL.load($('#photos'), "photos", false)
		dataSorted = @groupDataByDay(data)
		if @period == "week"
			dataSorted = @createWeekDays(dataSorted)
		else if @period == "month"
			dataSorted = @createMonthDays(dataSorted)
		@displayPhotos(dataSorted)
		graphic = new foodrubix.graphic(dataSorted, @period, @date)

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
			newDate = new Date(point.uploaded_at).clearTime()
			if dataSorted == []
				dataSorted.push({
					date: newDate,
					day_date: newDate.toString('dddd'),
					data_points: [point]
				})
			else
				added = false
				for day in dataSorted
					if newDate.compareTo(day.date) == 0
						day.data_points.push(point)
						added = true
				if !added
					dataSorted.push({
						date: newDate,
						day_date: newDate.toString('dddd'),
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
					date = new Date(dataPoint.uploaded_at)
					dataPoint.uploaded_at_readable = date.toString('hh:mm tt')
					dataPoint.uploaded_at_editable = date.toString('MM-dd-yyyy')
					dataPoint.time_uploaded_at = date.toString('hh:mm tt')
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
						date = new Date(dataPoint.uploaded_at)
						dataPoint.uploaded_at_readable = date.toString('hh:mm tt')
						dataPoint.uploaded_at_editable = date.toString('MM-dd-yyyy')
						dataPoint.time_uploaded_at = date.toString('hh:mm tt')
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

	unifyHeights: () ->
		fn = (weekSpans)->
			arr = weekSpans.map((i, el) ->
	            return $(el).outerHeight()
	        )
	        max = Math.max.apply(null, arr)
	        weekSpans.css('height', max)

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



	attachDragAndDrops:()->
		$(".span1_7 img").imagesLoaded(@unifyHeights)
		$(".week_view .image, .month_view .image").draggable();
		$(".week_view .span1_7, .month_view tbody .span1_7").droppable(
			hoverClass: "hoverActive",
			drop: @onDrop.bind @
		);

	onDrop:(event, ui)->
		# form the new date
		id = ui.draggable.attr("data-id")
		el = $(event.target)
		dateDrop = el.attr("data-date");
		date = Date.parse(dateDrop,"M-d-yyyy")
		timeVal = ui.draggable.find(".time").text()
		time = Date.parse(timeVal, 'hh:mm tt')
		date.set(
			hour:time.getHours(),
			minute:time.getMinutes()
			)
		# update date
		$.ajax({
			type: "PUT",
			url: '/data_points/'+id+'.json',
			data:
				data_point : {
					id: id,
					uploaded_at: date.toISOString()
				},
				dataType: 'json',
				success: @onSuccessAjax.bind @
		})

	userLikeImage: (userId, dataPoint) ->
		return like.id for like in dataPoint.likes when like.user_id.toString() == userId

	onHoverImage: (e) ->
		target = $(e.target)
		image = target.parents('.image')
		overlay = image.find(".overlay")
		image.find('.edit_data_point').toggleClass 'hide'

		if e.type == "mouseleave"
			overlay.stop(true, false).animate({
				bottom: '-44px'
				}, 300)
		else
			overlay.stop(true, false).animate({
				bottom: '0px'
				}, 300)



	initEditModal: (e) =>
		@activeModal = @uploadModal
		@uploadModal.initialize()

	fetchViewModal: (e) =>
		$.ajax({
			type: 'GET',
			url: '/data_points/'+@idImageClicked,
			dataType: 'script'
		})

	initViewModal: () ->
		@activeModal = new foodrubix.dataPointViewManager({
		 	el:$('.modal.in')
		 	master: @
		})

	onImageClick: (e) =>
		@idImageClicked = $(e.target).parents(".image").attr("data-id")


	onSuccessAjax: (data) =>

		$(".modal.in").modal('hide')
		if @activeModal && typeof @activeModal.clean == "function"
		  @activeModal.clean()
		@activeModal = ""
		UTIL.load($('#photos'), "photos", true)
		fn = ()->
			@refresh()
		_.delay(fn.bind(@), 1000) #we put a delay to give time to server to update before to refresh



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




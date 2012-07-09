foodrubix.users.show = () ->
	photoCalendar = new PhotoCalendar({el: $("#photoCalendar")})
	

class PhotoCalendar extends Spine.Controller
	
	events:
		"click .period": "changeView"
		"click .prev": "goToPrev"
		"click .next": "goToNext"
		"click .today": "gotToToday"
		"hover .image": "toggleEditIcon"
		"click .edit_data_point": "initUpdatePopup"
		"shown .modal": "updateCurrentModal"

	elements:
		"#photos": "photos"
		"#graphicContainer": "graphic"
		".period": "periodButtons"

	constructor: ()->
		super
		UTIL.load($('#photos'), "photos", true)
		@period = "week"
		@date = Date.today()
		@getDates("week", Date.today())
		@getDataPoints(@onSuccessFetch)
	
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
		console.log("@startDate, @endDate:",@startDate, @endDate);
		
	#make the ajax call to get the data points
	getDataPoints: (onSuccessFetch) ->
		$.ajax({
			type: 'GET',
			url: '/data_points.json',
			data: {
				start_date : @startDate.toISOString() ,
				end_date : @endDate.toISOString()
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
		console.log("data:",data);
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
				day_date: date.toString('d'),
				data_points: [],
				other_month:true
			})
			date.add(1).days()
			
		month.push(week)	
		console.log("monthData:",month);
		month
	
	#create an array of 7 items with empty days if there is no photo uploaded	
	createWeekDays: (data) ->
		console.log("data week days", data)
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
		console.log("grouped data:",dataSorted);
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
					dataPoint.uploaded_at_readable = date.toString('ddd MMM d yyyy - hh:mm tt')
					dataPoint.uploaded_at_editable = date.toString('MM-dd-yyyy')
					dataPoint.time_uploaded_at = date.toString('HH:mm')
		else if @period == "month"
			for week in data
				for day in week.week_data
					for dataPoint in day.data_points
						dataPoint.img_path = dataPoint.id + "/medium.jpg"
						date = new Date(dataPoint.uploaded_at)
						dataPoint.uploaded_at_readable = date.toString('ddd MMM d yyyy - hh:mm tt')
						dataPoint.uploaded_at_editable = date.toString('MM-dd-yyyy')
						dataPoint.time_uploaded_at = date.toString('HH:mm')
						
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

		$('.thumb').popover({
	 		delay: { show: 1000, hide: 100 }
	 	})


	toggleEditIcon: (e) ->
		target = $(e.target)
		target.parents('.image').find('.edit_data_point').toggleClass 'hide'

	initUpdatePopup: (e) ->
		$('.modal .datePicker').datepicker()
		$('.modal .timePicker').timePicker()
		$('.modal .btn-upload').click @changePhoto
		$('.modal .data_point_photo').change @onChangePhoto
		$('.modal .btn-save').click @validateUpdateData
		$('.modal .btn-delete').click @removeDataPoint
		$('.modal .btn-confirm-delete').click @showConfirmDeleteBox
	
	updateCurrentModal: (e) =>
		@activeModal = $('.modal.in')
	
	changePhoto: (e) =>
		file_input = $(e.target).next(".data_point_photo")
		file_input.click()
	
	onChangePhoto: (e) =>
		input = e.target
		if input.files && input.files[0]
			reader = new FileReader()
			reader.onload = (e) ->
				$(input).parent().find("img").attr('src', e.target.result);
			reader.readAsDataURL(input.files[0]);
	
	validateUpdateData: (e) =>
		validated = true
		id = @activeModal.attr('data-id')
		unless parseInt id
			throw "no id for update modal box"
		#remove all previous error 
		@activeModal.find(".control-group").removeClass('error')
		@activeModal.find(".help-inline").addClass('hide')
		
		# validate calories
		calories = @activeModal.find('#data_point_calories').val()
		unless parseInt calories
			validated = false
			@activeModal.find(".control-group.calories").addClass('error')
			@activeModal.find('.help-inline.calories').removeClass('hide')
	
		# validate date
		input = @activeModal.find('.datePicker input')
		dateVal = input.val()
		ISODate =  Date.parse(dateVal,"M-d-yyyy")
		unless ISODate
			validated = false
			@activeModal.find(".control-group.date").addClass('error')
			@activeModal.find('.help-inline.date').removeClass('hide')
			
		# validate time
		date = $.timePicker("#timePicker_"+id).getTime() 
		unless date 
			validated = false
			@activeModal.find(".control-group.time").addClass('error')
			@activeModal.find('.help-inline.time').removeClass('hide')
			
		ISODate.set(
			hour:date.getHours(),
			minute:date.getMinutes()
		)
		
		if validated
			@updateDataPoint(e, {
				id:id
				calories: calories
				uploaded_at: ISODate
			})
			
			
	# data should have id, calories, uploaded_at
	updateDataPoint: (e, data) =>
		$(e.target).button('loading')	
		progress = @activeModal.find('.progress')
		bar = progress.children()
		
		# 	update data 
		onSuccess = () ->
			$.ajax({
				type: "PUT",
				url: '/data_points/'+data.id+'.json',
				data: 
					data_point : data,
					dataType: 'json',
					success: @onSuccessUpdate.bind @
			})
			
		beforeSend = () ->
			progress.removeClass('hide').parent().find("a.btn").addClass('hide')
			percentVal = '0%';
			bar.width(percentVal)

		uploadProgress = (event, position, total, percentComplete) ->
			percentVal = percentComplete + '%';
			bar.width(percentVal)
		
		# update photo first
		form = $("#uploadForm_"+data.id);
		form.ajaxSubmit(
			type:"put"
			dataType:"json"
			success: onSuccess.bind @
			beforeSend: beforeSend.bind @
			uploadProgress: uploadProgress.bind @
		)

	
	
	showConfirmDeleteBox: () =>
		popup = @activeModal.find(".alert-delete").removeClass('hide')
	
	removeDataPoint: (e) =>
		$(e.target).button('loading')
		id = @activeModal.attr('data-id')
		$.ajax({
		          type: "DELETE",
		          url: '/data_points/'+id+'.json',
		          dataType: 'json',
		          success: @onSuccessUpdate.bind @
		})
		
	onSuccessUpdate: (data) =>
		fn = ()->
			$(".modal.in").modal('hide')
			@refresh()
		_.delay(fn.bind(@), 2000) #we put a delay to give time to server to update before to refresh
	
	
#manage graphics
class foodrubix.graphic 
	constructor: (@data, @view, @date_now) ->
		if @data.length
			#@displayData()
			@prepareDataForHighchart()
			if @view == "day"
				@displayDayChart()	
			else if @view == "week"
				@displayWeekChart()	
			else
				@displayMonthChart()
				
	displayDayChart: () =>
		nbPoints = @processedData.length
		$('#dayGraphicContainer').css height: nbPoints*200+125
		categories = [1..nbPoints]
		categories = _.map(categories, (num) -> "Photo "+num.toString())
		chart1 = new Highcharts.Chart({
			chart: {
				renderTo: 'dayGraphicContainer',
				type: 'bar',
				shadow:true,
				spacingRight:20
			},
			credits:{
				enabled:false
			}
			title: {
				text: 'Calories per meal'
			},
			xAxis: {
				categories: categories,
				title: {
					text: null
				}
			},
			yAxis: {
				title: {
					text: 'Calories'
				},
				min: 0
			},
			plotOptions: {
				bar: {
					dataLabels: {
						enabled: true
					}
				}				
			},
			series: [{
				name: 'Calories',
				data: @processedData
			}]
		})
		

	displayWeekChart: () =>
		categories = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
		chart1 = new Highcharts.Chart({
			chart: {
				renderTo: 'graphicContainer',
				type: 'line',
				shadow:true
			},
			credits:{
				enabled:false
			}
			title: {
				text: 'Calories per day'
			},
			xAxis: {
				categories: categories
			},
			yAxis: {
				title: {
					text: 'Calories'
				},
				min: 0
			},
			tooltip: {
				formatter: () -> return '<b>'+this.series.name+'</b><br/>'+this.x+': '+this.y+' calories';
			},
			plotOptions: {
				series: {
					cursor: 'pointer',
					events: {
						click: (e) ->
							console.log("this over:",this, e.point)	
						,
						mouseOut: (e) ->
							console.log("this out:",this, e)
					}
				}
			},
			series: [{
				name: 'Calories',
				data: @processedData
			}]
		})
			
	displayMonthChart: () =>

		chart1 = new Highcharts.Chart({
			chart: {
				renderTo: 'graphicContainer',
				type: 'line',
				shadow:true
			},
			credits:{
				enabled:false
			}
			title: {
				text: 'Calories per day'
			},
			xAxis: {
				type: 'datetime',
				labels: {
					formatter: () -> Highcharts.dateFormat('%b %d', this.value)
				}
			},
			yAxis: {
				title: {
					text: 'Calories'
				},
				min: 0
			},
			tooltip: {
				formatter: () -> 
					date = new Date(this.x)
					date_to_s = date.toString("dd MMM")
					'<b>'+this.series.name+'</b><br/>'+date_to_s+': '+this.y+' calories'
			},
			plotOptions: {
				series: {
					cursor: 'pointer',
					events: {
						click: (e) ->
							console.log("this over:",this, e.point)	
						,
						mouseOut: (e) ->
							console.log("this out:",this, e)
					}
				}
			},
			series: [{
				name: 'Calories',
				data: @processedData
			}]
		})

	prepareDataForHighchart: () ->
		@processedData = []
		if @view == "week"
			for day in @data
				dayCalories = 0
				for dataPoint in day.data_points
					dayCalories += dataPoint.calories
				@processedData.push(dayCalories)
		else if @view == "month"
			for week in @data
				for day in week.week_data
					dayCalories = 0
					for dataPoint in day.data_points
						dayCalories += dataPoint.calories
					if day.date.getMonth() == @date_now.getMonth()
						@processedData.push([day.date.clearTime().valueOf(), dayCalories])
		else if @view == "day"
			for day in @data
				for dataPoint in day.data_points 
					@processedData.push dataPoint.calories
		
					
	
        
	
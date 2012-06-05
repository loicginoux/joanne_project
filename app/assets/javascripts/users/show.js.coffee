foodrubix.users.show = () ->
	photoCalendar = new PhotoCalendar({el: $("#photoCalendar")})
	

class PhotoCalendar extends Spine.Controller
	
	events:
		"click .period": "changeView"
		"click .prev": "goToPrev"
		"click .next": "goToNext"
		"click .today": "gotToToday"

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
		@getDataPoints(@onSuccess)
		
	#get start date and end date from a period and a date
	# period is "day" or "week" or "month"
	getDates: (period, date) ->
		@startDate = date.clone()
		@endDate = date.clone()
		switch @period
		  # body... @period
			when "day" then @endDate.add(1).days()
			when "week" then @startDate.last().monday(); @endDate.next().monday()
			when "month" then @startDate.moveToFirstDayOfMonth(); @endDate.moveToLastDayOfMonth()
		console.log("@startDate, @endDate:",@startDate, @endDate);
		
	#make the ajax call to get the data points
	getDataPoints: (onSuccess) ->
		$.ajax({
			type: 'GET',
			url: '/data_points.json',
			data: {
				start_date : @startDate.toISOString() ,
				end_date : @endDate.toISOString()
			},
			dataType: 'json', 
			success: onSuccess.bind @
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
			@getDataPoints(@onSuccess)
	
	goToPrev: () ->
		UTIL.load($('#photos'), "photos", true)
		@graphic.empty()
		
		switch @period
			when "day" then @date.add(-1).days()
			when "week" then @date.add(-7).days()
			when "month" then @date.add(-30).days()
				
		@getDates(@period, @date)
		@getDataPoints(@onSuccess)
	
	goToNext: () ->
		UTIL.load($('#photos'), "photos", true)
		@graphic.empty()
		
		switch @period
			when "day" then @date = @date.add(1).days()
			when "week" then @date = @date.add(7).days()
			when "month" then @date = @date.add(30).days()
				
		@getDates(@period, @date)
		@getDataPoints(@onSuccess)
		
	gotToToday: () ->
		UTIL.load($('#photos'), "photos", true)
		@graphic.empty()
		@getDates(@period, Date.today())
		@getDataPoints(@onSuccess)
	
	#function to run on success of the ajax call
	#data are data points
	onSuccess: (data) ->
		console.log("data:",data);
		#display loading gif
		UTIL.load($('#photos'), "photos", false)
		dataSorted = @groupDataByDay(data)
		@displayPhotos(dataSorted)
		graphic = new foodrubix.graphic(dataSorted, @period )

	# group data by day
	# return data sorted by date
	# [{date: date, data:[]}]
	groupDataByDay: (data) ->
		dataSorted = []
		for point in data
			newDate = new Date(point.created_at).clearTime()
			if dataSorted == []
				dataSorted.push({
					date: newDate,
					day_date: newDate.toString('dddd dd'),
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
						day_date: newDate.toString('dddd dd'),
						data_points: [point]
					})
		console.log("grouped data:",dataSorted);
				
		return dataSorted	
	
	
	#display the photo list	
	#data has the form [{date:Date, data_points:[data_point]}]
	# view is the number of day to display
	displayPhotos: (data) ->
		group = []
		incr = 0
		$('#photos').empty()
		for day in data
			for dataPoint in day.data_points
				dataPoint.img_path = dataPoint.id + "/medium.jpg"
				dataPoint.created_at_readable = new Date(dataPoint.created_at).toString('ddd MMM d yyyy hh:mm:ss')
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
				startDate: @startDate.toString("d MMM")
				endDate: @endDate.toString("d MMM")
				year: @endDate.toString("yyyy")
			}
		else if (@period == "month")
			tmpl = $('#month_photos_tmpl').html()
			json = {
				data:data, 
				startDate: @startDate.toString("d MMM")
				endDate: @endDate.toString("d MMM")
				year: @endDate.toString("yyyy")
			}
		$('#photos').append(Mustache.render(tmpl, json ))
		$('.thumb').popover({
	 		delay: { show: 1000, hide: 100 }
	 	})
	
	
#manage graphics
class foodrubix.graphic 
	constructor: (@data, @view) ->
		if @data.length
			#@displayData()
			@displayHighchart()
	
	displayHighchart: () =>
		data = @prepareDataForHighchart()
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
				dateTimeLabelFormats: {
					month: '%e. %b',
					year: '%b'
				}
			},
			yAxis: {
				title: {
					text: 'Calories'
				},
				min: 0
			},
			tooltip: {
				formatter: () -> return '<b>'+this.series.name+'</b><br/>'+Highcharts.dateFormat('%e. %b', this.x)+': '+this.y+' Calories';
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
				data: data
			}]
		})
			
	# displayData: () =>
	# 	jqplotData = @prepareInputFormat()
	# 	format = if @view != 0 then '%#d %b' else '%#d %b - %Hh'
	# 	title = if @view != 0 then 'Calories per day' else 'Calories for '+ @data[0].day_date
	# 	$.jqplot('graphicContainer',
	# 		[jqplotData], 
	# 		{axes:{
	# 			xaxis:{
	# 				renderer:$.jqplot.DateAxisRenderer,
	# 				tickOptions:{
	#                     	formatString: format
	# 				}
	# 			},
	# 			yaxis:{
	# 				min: 0,
	# 				tickInterval:200
	# 			}
	# 		}, 
	# 		title:title,
	# 		highlighter: {
	# 			show: true,
	# 			sizeAdjust: 20
	# 		},
	# 		cursor: {
	# 			show: false
	# 		}
	# 		}
	# 	)
	prepareDataForHighchart: () ->
		jqplotData = []
		if @view != 0
			for day in @data
				dayCalories = 0
				for dataPoint in day.data_points
					dayCalories += dataPoint.calories
				jqplotData.push([new Date(day.data_points[0].created_at).add(1).days().clearTime().valueOf(), dayCalories])
		else
			for day in @data
				for dataPoint in day.data_points
					jqplotData.push [new Date(dataPoint.created_at).valueOf(), dataPoint.calories]
		jqplotData
			
	# prepareInputFormat: () ->
	# 	if @view != 0
	# 		jqplotData = @groupDataByDay(@data)
	# 	else
	# 		jqplotData = []
	# 		for day in @data
	# 			for dataPoint in day.data_points
	# 				jqplotData.push [new Date(dataPoint.created_at), dataPoint.calories]
	# 	console.log("jqplotData:",jqplotData);		
	# 	return jqplotData
				
	#should return something like
	#[['2011-05-03 10:15:30', 25], ['2011-05-04 11:30:30', 30]]
	groupDataByDay: (data) ->
		jqplotData = []
		#we first group by day
		for day in data
			dayCalories = 0
			for dataPoint in day.data_points
				dayCalories += dataPoint.calories
			jqplotData.push([new Date(day.data_points[0].created_at).clearTime().toDateString(), dayCalories])
		jqplotData

		
					
	
        
	
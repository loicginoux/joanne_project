foodrubix.users.show = () ->
	UTIL.load($('#photos'), "photos", true)
	startDate = Date.today().add(-7).days().toISOString()
	endDate = Date.today().add(1).days().toISOString()
	getDataPoints(startDate, endDate, onSuccess, 7)


	$('div.btn-last button').bind 'click', (e) ->
		UTIL.load($('#photos'), "photos", true)
		$('#chartdiv').empty()
		$('div.btn-last button').removeClass 'active'
		self = $(this)
		self.addClass 'active'
		lastDays = parseInt(self.attr("data-lastDays"))
		startDate = Date.today().add(lastDays).days().toISOString()
		endDate = Date.today().add(1).days().toISOString()
		getDataPoints(startDate, endDate, onSuccess, lastDays)


#make the ajax call to get the data points
getDataPoints = (startDate, endDate, onSuccess, lastDays) ->
	console.log("startDate, endDate:",startDate, endDate);
	
	$.ajax({
		type: 'GET',
		url: '/data_points.json',
		data: {
			start_date:startDate ,
			end_date: endDate
		},
		dataType: 'json', 
		success:(data)->
			onSuccess(data,lastDays)
	})


#function to run on success of the ajax call
#data are data points, lastDays is the number of days to show (1, -6, -30)
onSuccess = (data, lastDays) ->
	#display loading gif
	UTIL.load($('#photos'), "photos", false)
	dataSorted = groupDataByDay(data)
	displayPhotos(dataSorted)
	graphic = new foodrubix.graphic(dataSorted,lastDays)


# group data by day
# return data sorted by date
# [{date: date, data:[]}]
groupDataByDay = (data) ->
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
displayPhotos = (data) ->
	group = []
	incr = 0
	$('#photos').empty()
	for day in data
		for dataPoint in day.data_points
			dataPoint.img_path = dataPoint.id + "/medium.jpg"
			dataPoint.created_at_readable = new Date(dataPoint.created_at).toString('ddd MMM d yyyy hh:mm:ss')
	tmpl = $('#photos_tmpl').html()
	$('#photos').append(Mustache.render(tmpl, {data:data}))
	$('.thumb').popover({
 		delay: { show: 1000, hide: 100 }
 	})
	
	
#manage graphics
class foodrubix.graphic 
	constructor: (@data, @view) ->
		if @data.length
			@displayData()
		
	displayData: () =>
		jqplotData = @prepareInputFormat()
		format = if @view != 0 then '%#d %b' else '%#d %b - %Hh'
		title = if @view != 0 then 'Calories per day' else 'Calories for '+ @data[0].day_date
		$.jqplot('chartdiv',
			[jqplotData], 
			{axes:{
				xaxis:{
					renderer:$.jqplot.DateAxisRenderer,
					tickOptions:{
                    	formatString: format
					}
				},
				yaxis:{
					min: 0,
					tickInterval:200
				}
			}, 
			title:title,
			highlighter: {
				show: true,
				sizeAdjust: 20
			},
			cursor: {
				show: false
			}
			}
		)
	
	prepareInputFormat: () ->
		if @view != 0
			jqplotData = @groupDataByDay(@data)
		else
			jqplotData = []
			for day in @data
				for dataPoint in day.data_points
					jqplotData.push [new Date(dataPoint.created_at), dataPoint.calories]
		console.log("jqplotData:",jqplotData);		
		return jqplotData
				
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

		
					
	
        
	
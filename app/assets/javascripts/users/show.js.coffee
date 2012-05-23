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
onSuccess = (data, lastDays) ->
	UTIL.load($('#photos'), "photos", false)
	console.log("success:",data, lastDays);
	displayPhotos(data);	
	graphic = new foodrubix.graphic(data,lastDays)

#display the photo list			
displayPhotos = (data) ->
	group = []
	incr = 0
	json_photos = {photos:[]}
	$('#photos').empty()
	#we format the date, build the img url and group them by 6
	for dataPoint in data
		if incr == 6 
			incr = 1 
			group.push(json_photos)
			json_photos = {photos:[]}
		else 
			incr += 1 
		dataPoint.created_at_readable = new Date(dataPoint.created_at).toString('dd-MMM-yyyy')
		dataPoint.img_path = dataPoint.id + "/thumb.jpg"
		json_photos.photos.push dataPoint
	
	group.push(json_photos)
		
	tmpl = $('#photos_tmpl').html()
	for json_photos in group
		$('#photos').append("<div class='row'>"+Mustache.render(tmpl, json_photos)+"</div>")
	

	
#manage graphics
class foodrubix.graphic 
	constructor: (@data, @view) ->
		if @data.length
			@displayData()
		
	displayData: () =>
		console.log("@data:",@data, @view);
		jqplotData = @prepareInputFormat()
		console.log("jqplotData:",jqplotData);
		max_axis_x = new Date(jqplotData[jqplotData.length-1][0]).add(1).days().toString('dd-MMM-yyyy')
		$.jqplot('chartdiv',
			[jqplotData], 
			{axes:{
				xaxis:{
					renderer:$.jqplot.DateAxisRenderer,
					tickOptions:{
                    	formatString:'%#d %b'
					},
					max: max_axis_x
				},
				yaxis:{
					min: 0,
					tickInterval:200
				}
			}, 
			title:"calories per day",
			series:[{lineWidth:4, markerOptions:{style:'square'}}],
			gridPadding:{right:35},
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
			for point in @data
				jqplotData.push [new Date(point.created_at), point.calories]
		return jqplotData
				
	#should return something like
	#[['2011-05-03 10:15:30', 25], ['2011-05-04 11:30:30', 30]]
	groupDataByDay: (data) ->
		jqplotData = []
		#we first group by day
		for point in data
			newDate = new Date(point.created_at).clearTime()
			if jqplotData == []
				jqplotData.push [newDate, point.calories]
			else
				added = false
				for graphpoints in jqplotData
					if newDate.compareTo(graphpoints[0]) == 0
						graphpoints[1] += point.calories
						added = true
				if !added					
					jqplotData.push [newDate, point.calories]
		 
		for data in jqplotData			
			data[0] = data[0].toDateString()
			
		return jqplotData
		
					
	
        
	
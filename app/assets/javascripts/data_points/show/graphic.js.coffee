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
		settings = {
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
				min: 0,
				max: @maxGraph()
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
		}
		if gon.daily_calories_limit != 0
			settings.yAxis.plotLines = [{
				value : gon.daily_calories_limit,
				color : '#e96000',
				dashStyle : 'longdashdot',
				width : 2,
				label : {
					text : 'daily goal'
				}
			}]
		chart1 = new Highcharts.Chart(settings)

	displayMonthChart: () =>
		settings = {
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
				min: 0,
				max: @maxGraph()
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
		}
		if gon.daily_calories_limit != 0
			settings.yAxis.plotLines = [{
				value : gon.daily_calories_limit,
				color : '#e96000',
				dashStyle : 'longdashdot',
				width : 2,
				label : {
					text : 'daily goal'
				}
			}]

		chart1 = new Highcharts.Chart(settings)

	maxGraph:()->
		max = gon.daily_calories_limit
		for points in @processedData
			console.log points, max
			if points[1]>max
				max = null
				break
		return max

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





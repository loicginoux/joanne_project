#manage graphics
class foodrubix.graphic
	constructor: () ->
		that = @
		window.Spine.bind 'data_points:loaded', (data, view) ->
			that.view = view
			that.data = data
			that.maxPoints = that.maxGraph()
			if that.maxPoints && that.maxPoints > 0
				if view == "day"
					that.displayDayChart()
				else if view == "week"
					that.displayWeekChart()
				else
					that.displayMonthChart()

	displayDayChart: () =>
		nbPoints = @data.length
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
			colors: ['#E96000'],
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
				data: @data
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
				data: @data
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
				max: @max
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
				data: @data
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
		for points in @data
			points = if (typeof points  == "number") then points else points[1]
			if points>max
				max = points
		return max


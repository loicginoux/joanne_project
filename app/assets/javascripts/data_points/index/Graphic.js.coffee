#manage graphics
class foodrubix.Graphic extends Spine.Controller
	el: $("#graphic")

	elements:
		".compare": "compareBtn"
		".graphicContainer": "graphicContainer"

	events:
		"click .compare": "clickCompare"

	constructor: () ->
		super

	onDataPointsLoaded: (data) ->
		# @log("data points loaded", data, @)
		@data = data
		current_max = @maxGraph(@data.current_period)
		prev_max = @maxGraph(@data.previous_period)
		@maxPoints =  if (current_max > prev_max) then current_max else prev_max
		@display() if @maxPoints && @maxPoints > 0

	display: () =>
		@compareBtn.show()
		@series = [{
				name: 'Calories',
				data: @data.current_period,
				color: "#e96000",
				zIndex: 2,
				fillOpacity: 0.1,
				id:"current"
		}]
		@settings = {
			chart: {
				type: 'areaspline',
				shadow:true,
				height: 400
			},
			credits:{
				enabled:false
			}
			title: {
				text: 'Calories per day'
			},
			yAxis: {
				title: {
					text: 'Calories'
				},
				min: 0,
				max: @maxPoints + 100,
				gridLineWidth: 1,
				gridLineDashStyle: 'longdash'
				gridLineColor: "#ddd"
			},
			legend: {
				layout: 'vertical',
				align: 'right',
				verticalAlign: 'top',
				x: -150,
				y: 100,
				floating: true,
				borderWidth: 1,
				backgroundColor: '#FFFFFF'
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
				},
				areaspline: {
					fillOpacity: 0.3
				}
			}
		}

		if gon.daily_calories_limit != 0
			console.log("here")
			@settings.yAxis.plotLines = [{
				value : gon.daily_calories_limit,
				color : '#e96000',
				dashStyle : 'longdashdot',
				width : 2,
				label : {
					text : 'daily goal'
				}
			}]


	# compare current period with previous one
	clickCompare:	(e) =>
		# if no comparison
		if Spine.Route.getPath().indexOf("compare") == -1
			# we fetch new data and compare
			@navigate(Spine.Route.getPath(), "compare")
		else
			# we remove the graphic line for previous period
			@navigate(Spine.Route.getPath().replace("/compare", ""), {trigger: false})
			delete @data.previous_period
			@adjustCompareBtnState({compare:false}, @master.period)
			@display()
			$("html, body").animate({scrollTop: (@compareBtn.offset().top - 70)}, 1000);


	compare:	(e) =>
		@master.stack.getDataPoints(@master.stack.onSuccessFetch, @master.getComparisonDates())

	adjustCompareBtnState: (options, period) ->
		# @log "compare", options.compare
		if options.compare
			@compareBtn.html("Remove Comparison")
		else
			@compareBtn.html("Compare to Last "+period.slice(0,1).toUpperCase()+period.slice(1))

	# get max point on the graph depending on the array data and the daily calorie limit
	maxGraph:(data)->
		return 0 unless data
		# max = gon.daily_calories_limit
		max = 0
		for points in data
			points = if (typeof points  == "number") then points else points[1]
			if points>max
				max = points
		if max > 0 && max < gon.daily_calories_limit
			max = gon.daily_calories_limit
		max

	cancel:() ->
		@log "cancel"
		@el.undelegate(".compare", "click")
		@graphicContainer.empty()
		@compareBtn.hide()
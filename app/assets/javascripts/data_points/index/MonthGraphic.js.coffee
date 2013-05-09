#= require data_points/index/Graphic

class foodrubix.MonthGraphic extends foodrubix.Graphic
	constructor: () ->
		super

	display: () =>
		super
		that = @
		if @data.previous_period
			@series[0].name = "Current Month Calories"
			@series.push({
				name: 'Last Month Calories',
				data: @data.previous_period,
				color: "#058dc7",
				fillOpacity: 0.1,
				id:"previous"
			})

		@settings = $.extend({}, @settings, {
			xAxis: {
				# type: 'datetime',
				# labels: {
				# 	formatter: () -> Highcharts.dateFormat('%b %d', this.value)
				# },
				categories: [1..31],
				gridLineWidth: 1,
				gridLineDashStyle: 'longdash'
				gridLineColor: "#ddd"
			}
			tooltip: {
				formatter: () ->
					monthDay = this.x
					serie_index = this.series.index
					that.log serie_index
					if serie_index == 0
						month = that.master.stack.date.toString("MMM")
					else
						month = that.master.stack.date.clone().addMonths(-1).toString("MMM")

					'<b>'+this.series.name+'</b><br/>'+monthDay+" "+month+': '+this.y+' calories'
			},
			series: @series
		})

		@graphicContainer.highcharts(@settings)


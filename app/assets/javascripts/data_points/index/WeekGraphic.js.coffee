#= require data_points/index/Graphic

class foodrubix.WeekGraphic extends foodrubix.Graphic
	constructor: () ->
		super

	display: () ->
		super
		categories = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']


		if @data.previous_period
			@series[0].name = "Current Week Calories"
			@series.push({
				name: 'Last Week Calories',
				data: @data.previous_period,
				color: "#058dc7",
				fillOpacity: 0.1,
				id:"previous"
			})
			$("html, body").animate({scrollTop: (@compareBtn.offset().top - 70)}, 1000);

		@settings = $.extend({}, @settings, {
			xAxis: {
				categories: categories,
				gridLineWidth: 1,
				gridLineDashStyle: 'longdash'
				gridLineColor: "#ddd"
			},
			tooltip: {
				formatter: () -> return '<b>'+this.series.name+'</b><br/>'+this.x+': '+this.y+' calories';
			}
			series: @series
		})

		@graphicContainer.highcharts(@settings)

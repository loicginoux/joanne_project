#= require data_points/index/Graphic

class foodrubix.DayGraphic extends foodrubix.Graphic

	constructor: () ->
		super
		@compareBtn = $(".compare")

	onDataPointsLoaded: (data) ->
		@log("data points loaded", data, @)
		@compareBtn.hide()
		@el = $("#dayGraphicContainer")
		$(".graphicContainer").empty()

		@data = data
		@display() if data.length

	display: () =>
		nbPoints = @data.length

		@el.css height: nbPoints*200+125
		categories = [1..nbPoints]
		categories = _.map(categories, (num) -> "Photo "+num.toString())
		settings = {
			chart: {
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
		}
		@el.highcharts(settings)


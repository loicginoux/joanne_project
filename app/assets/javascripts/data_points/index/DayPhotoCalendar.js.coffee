#= require data_points/index/PhotoCalendar

class foodrubix.DayPhotoCalendar extends foodrubix.PhotoCalendar
	constructor: () ->
		@period = "day"
		super

	activate: () ->
		super

	initGraphic:() ->
		super
		@graphic = new foodrubix.DayGraphic({master:@})

	getDates: () ->
		super
		@stack.endDate.set({hour:23, minute:59, second:59})

	# get dates for the previous period when comparing
	getComparisonDates: () ->
		return {
			start_date: @stack.startDate.clone().addDays(-1)
			end_date: @stack.startDate.clone().addSeconds(-1)
		}

	goTo:(multiple)->
		@stack.date.addDays(1*multiple)
		super

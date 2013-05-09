#= require data_points/index/PhotoCalendar

class foodrubix.WeekPhotoCalendar extends foodrubix.PhotoCalendar
	constructor: (settings) ->
		@period = "week"
		super

	initGraphic:() ->
		super
		@graphic = new foodrubix.WeekGraphic({master:@})

	getDates: () ->
		super
		@stack.startDate.last().sunday() unless @stack.date.is().sunday()
		@stack.startDate.clearTime()
		@stack.endDate.next().saturday() unless @stack.date.is().saturday()
		@stack.endDate.set({hour:23, minute:59, second:59})

	# get dates for the previous period when comparing
	getComparisonDates: () ->
		return {
			start_date: @stack.startDate.clone().addWeeks(-1)
			end_date: @stack.startDate.clone().addSeconds(-1)
		}

	goTo:(multiple)->
		@stack.date.addWeeks(1*multiple)
		super

	unifyHeights: () ->
		weekSpans = $('.week_view .span1_7')
		if weekSpans.length
			@unifySpanHeights(weekSpans)

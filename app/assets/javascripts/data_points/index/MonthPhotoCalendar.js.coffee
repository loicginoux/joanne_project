#= require data_points/index/PhotoCalendar

class foodrubix.MonthPhotoCalendar extends foodrubix.PhotoCalendar
	constructor: () ->
		@period = "month"
		super

	initGraphic:() ->
		super
		@graphic = new foodrubix.MonthGraphic({master:@})

	getDates: () ->
		super
		@stack.startDate.moveToFirstDayOfMonth().clearTime()
		@stack.endDate.moveToLastDayOfMonth().set({hour:23, minute:59, second:59})

	# get dates for the previous period when comparing
	getComparisonDates: () ->
		return {
			start_date: @stack.startDate.clone().addMonths(-1)
			end_date: @stack.startDate.clone().addSeconds(-1)
		}

	goTo:(multiple)->
		@stack.date.addMonths(1*multiple)
		super

	unifyHeights: () ->
		that = @
		$(".month_view tbody tr").each((i, el)->
			weekSpans = $(el).find(".span1_7")
			that.unifySpanHeights(weekSpans)
		)
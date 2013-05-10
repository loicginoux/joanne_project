#= require data_points/index/WeekPhotoCalendar
#= require data_points/index/MonthPhotoCalendar
#= require data_points/index/DayPhotoCalendar

class foodrubix.PhotoCalendarManager extends Spine.Stack
	el:$("#photoCalendar")

	controllers:
    weekController : foodrubix.WeekPhotoCalendar
    monthController: foodrubix.MonthPhotoCalendar
    dayController  : foodrubix.DayPhotoCalendar

	routes:
		'week'                            : 'weekController'
		'week/:day/:month/:year'          : 'weekController'
		'week/:day/:month/:year/:compare' : 'weekController'
		'week/:compare'                   : 'weekController'

		'month'                           : 'monthController'
		'month/:day/:month/:year'         : 'monthController'
		'month/:day/:month/:year/:compare': 'monthController'
		'month/:compare'                  : 'monthController'

		'day'                             : 'dayController'
		'day/:day/:month/:year'           : 'dayController'

	events:
		# "click .period"          : "changePeriod"
		"click .prev"              : "goToPrev"
		"click .next"              : "goToNext"
		"click .today"             : "goToToday"
		"shown .modal.uploadPhoto" : "initUploadModal"
		"hidden .modal.uploadPhoto": "cleanUploadModal"
		"shown .modal.viewPhoto"   : "fetchViewModal"
		"hidden .modal.viewPhoto"  : "cleanViewModal"
		"modalRendered .viewPhoto" : "initViewModal"

	elements:
		"#photos"    : "photos"
		".period"    : "periodButtons"
		".emptyState": "emptyState"

	constructor: ()->
		super
		@userId = @el.attr("data-user")
		@period = if (UTIL.readCookie("period")) then UTIL.readCookie("period") else "week"
		@date = Date.today()
		Spine.Route.setup()
		unless Spine.Route.getPath()
			@navigate(@period, @date.toString("d/M/yyyy"))
		@uploadModal = new foodrubix.DataPointUploadModal({
			el:$('.modal.uploadPhoto')
			master: @
		})
		that = this
		window.Spine.bind('data_points:loaded', (data) ->
			that.activeController.graphic.onDataPointsLoaded(data)
		)



	# refresh the photos on the page
	refresh: () ->
		@getDataPoints(@onSuccessFetch)



	#make the ajax call to get the data points
	# for current user and between the @startDate and @endDate
	# param previousDates is optional, if set,
	# it will also fetch graphic datas from the previous period
	getDataPoints: (onSuccessFetch, previousDates) ->

		data = {
			start_date : UTIL.prepareForServer(@startDate) ,
			end_date : UTIL.prepareForServer(@endDate),
			user_id: @userId
			period: @period
		}

		if previousDates && previousDates.start_date && previousDates.end_date
			previousDates.start_date  = UTIL.prepareForServer(previousDates.start_date)
			previousDates.end_date = UTIL.prepareForServer(previousDates.end_date)
			data.previousDates = previousDates


		that = @
		$.ajax({
			type: 'GET',
			url: '/'+@period+'_data_points.js',
			data: data,
			dataType: 'script',
			# success: @onSuccessFetch.bind(@),
			complete: (xhr, status)->
				if status == 'error' || !xhr.responseText
        	console.log("error fetching data points", a,b)
    		else
        	that.onSuccessFetch()
			# error: (a,b,c)-> ,
		})

	# change the views from month, week or day view
	changePeriod: (period) ->
		btn = $(".period."+period)
		unless btn.hasClass('active')
			@periodButtons.removeClass 'active'
			btn.addClass 'active'
			@period = btn.attr("data-period")
			# @date = Date.today()
			UTIL.setCookie("period", @period, 30)




	# go to the previous month/week/day depending on current displayed period
	goToPrev: () ->
		@activeController.goTo(-1)

	# go to the next month/week/day depending on current displayed period
	goToNext: () ->
		@activeController.goTo(1)


	# display the right period which includes the day of today
	goToToday: () ->
		@date = Date.today()
		@navigate(@period, @date.toString("d/M/yyyy"))

	#function to run on success of the ajax call to get data points
	#data are data points
	onSuccessFetch: (data) =>
		@activeController.unload()
		@activeController.attachDragAndDrops() if gon.isCurrentUserDashboard
		@activeController.applyHoverImage()


	#  called when we click the upload button and the modal box appears
	initUploadModal: (e) =>
		@activeModal = @uploadModal
		@uploadModal.initialize()

	#  called when we close the upload modal box
	cleanUploadModal: (e) =>
		@uploadModal.clean()

	# loads the view template of a data point
	# called when we click on a photo
	fetchViewModal: (e) =>
		$.ajax({
			type: 'GET',
			url: '/data_points/'+@activeController.idImageClicked,
			dataType: 'script'
		})

	#  clear the view modal html when closing the view modal box
	cleanViewModal:()=>
		@activeModal.release()

	# called when the modal box for the view image is rendered
	initViewModal: () ->
		$(".modal.in").removeClass("hide")
		@activeModal = new foodrubix.dataPointViewManager({
		 	el:$('.modal.in .modal-body').children()
		 	master: @
		})

	# when a photo is edited or created, we need to refresh the view to
	# include the new photo
	onSuccessAjax: (data) =>
		$(".modal.in").modal('hide')
		if @activeModal
			if typeof @activeModal.clean == "function"
				@activeModal.clean()
			else
				@activeModal.release()
		@emptyState.addClass("hide")
		fn = ()->
			@refresh()
		_.delay(fn.bind(@), 1000) #we put a delay to give time to server to update before to refresh


class foodrubix.PhotoCalendar extends Spine.Controller
	el:$(".photos_and_graph")

	elements:
		"#photos": "photos"

	events:
		"click .image": "onImageClick"


	#get start date and end date from a period and a date
	# period is "day" or "week" or "month"
	# date is a Date object
	constructor: (settings) ->
		super
		@urlDateParser = "d/M/yyyy"
		@isActive = false
		@.bind("navigate", @initGraphic)

	getDates: () ->
		@stack.startDate = @stack.date.clone()
		@stack.endDate = @stack.date.clone()

	# get dates for the previous period when comparing
	getComparisonDates: () ->
		throw "implemented in subclass"

	goTo:(multiple)->
		@load()
		@navigate(@period, @stack.date.toString(@urlDateParser) )

	unifyHeights: () ->

	isActive: () => @isActive

	initGraphic:() ->
		@log "initGraphic"
		if @graphic
			@graphic.cancel()

	activate:(options) =>
		@log "activate"
		@isActive = true
		@initGraphic()
		@setDateFromHash(options)
		@stack.date = @urlDate if @urlDate
		@stack.changePeriod(@period)
		@getDates()
		@stack.activeController = @
		# @log Spine.Route.getPath()
		if Spine.Route.getPath().indexOf("/compare") != -1
			@log "compare from route"
			@graphic.compare()
		else
			@stack.getDataPoints(@onSuccessFetch)
		@

	deactivate:() =>
    @isActive = false
    @load()
   	@el.undelegate(".image", "mouseenter mouseleave")
    @

  setDateFromHash: (options) ->
  	if options
  		day = options.day
  		month = options.month
  		year = options.year
  		if day && month && year
  			@urlDate = Date.parseExact([day, month, year].join("/"), @urlDateParser)

  applyHoverImage:() ->
  	@el.delegate(".image", "mouseenter mouseleave", @onHoverImage.bind(@))

  load: ()->
  	UTIL.load(@photos, "photos", true)

  unload: ()->
  	$(".loading").remove()

  #  when hovering an image
	onHoverImage: (e) ->
		target = $(e.target)
		image = target.parents('.image')
		if !image.length then image = target
		overlay = image.find(".overlay")

		if e.type == "mouseleave"
			overlay.stop().animate({
				bottom: '-45px'
				}, 300)
		else
			overlay.stop().animate({
				bottom: '0px'
				}, 300)

	# when we drag and drop images around, we need to resize the css height of the day/week/month
	unifySpanHeights: (weekSpans) ->
		arr = weekSpans.map((i, el) ->
            return $(el).outerHeight()
        )
        max = Math.max.apply(null, arr)
		if (weekSpans.find(".sortableImages").children().length)
			sortableImagesHeight = max-18
		else
			sortableImagesHeight = 20
		weekSpans.find(".sortableImages").css("height",sortableImagesHeight).end().eq(0).parent().css('height', max+10)


	onImageClick: (e) =>
		@idImageClicked = if ($(e.target).attr("data-id")) then $(e.target).attr("data-id") else $(e.target).parents(".image").attr("data-id")

	# attach the drag and drop feature to move photos around
	attachDragAndDrops:()->
		$(".span1_7 img").imagesLoaded(@unifyHeights.bind(@))
		that = @
		# overflow is used when the images overflow the height of the week height
		overflow = false
		# canResize is used to tell to resize the day when went out from
		canResize = false
		# the number of pixel we resise at
		canResizeAt = 0
		placeHolderHeight = 0
		# which element to resize after going out of a connected list
		elemOutResize = ""
		# this is for the copy option
		@ctrlDown = false
		ctrlKey = 17
		cmdKey = 91

		$(".sortableImages").sortable({
			connectWith: ".sortableImages",
			helper: "clone",
			start: (e, ui)-> # when we start drag and drop
				placeHolderHeight = ui.item.height()
				ui.placeholder.height(placeHolderHeight)
				that.sortedItemIndex = ui.item.index()
				that.sortedDayFrom = ui.item.parent()
				ui.item.parent("ul").addClass "hoverActive"
				that.copyItem = false
				if that.ctrlDown
					$(ui.item).show()
					that.copyItem = true
			# out and over are only use in week and month view where we use connected lists
			out: (e, ui)-> # when going out of a connected list
				# that.log "out", $(e.target).parent().index()
				# overflow is set while going over a connected list
				if overflow
					# we could resize here but in some case it doesn't work,
					# so I resize on over
					canResize = true
					# that.log "out of overflow"
					target = $(e.target)
					targetHeight = target.height()
					canResizeAt = targetHeight - placeHolderHeight
					parentTr = target.parent().parent("tr")
					if parentTr.length
						elemOutResize = parentTr.find(".sortableImages")
					else
						elemOutResize = $(".sortableImages")
			over: (e, ui)-> # when going over a connected list
				# that.log "over", $(e.target).parent().index()
				$(".sortableImages").removeClass "hoverActive"
				target = $(e.target)
				target.addClass "hoverActive"
				# the element to resize "elemToResize" depends on the week or month view
				parentTr = target.parent().parent("tr")
				if parentTr.length
						elemToResize = parentTr.find(".sortableImages")
					else
						elemToResize = $(".sortableImages")
				# this is set up on the "out" event
				if canResize
					# @log "canResize", canResize, canResizeAt
					# we resize the element we go out from
					elemOutResize.height( canResizeAt )
				# if when dragging over the content overflow the height
				# we need to adjust the height of the week
				if that.checkOverflow(e.target)
					overflow = true
					# that.log "overflow"
					targetHeight = target.height()
					elemToResize.height(targetHeight + placeHolderHeight )
				else
					overflow = false
				return true
			stop: (e,ui) ->
				that.onDrop(e,ui)
		})

		# if we keep control or command while dragging we copy the photo
		$(document)
		.unbind("keydown.copy")
		.unbind("keyup.copy")
		.bind("keydown.copy", (e)->
			if (e.keyCode == ctrlKey || e.keyCode == cmdKey)
				that.ctrlDown = true
				# if ctrl or cmd is down, this is a copy of photo
				$( ".sortableImages" ).sortable( "option", "helper", "clone" );
    )
    .bind("keyup.copy", (e)->
    	if (e.keyCode == ctrlKey || e.keyCode == cmdKey)
    		that.ctrlDown = false
    		# if ctrl or cmd is up, dragging is to move the photo
    		$( ".sortableImages" ).sortable( "option", "helper", "original" );
    )

	# Determines if the passed element is overflowing its bounds,
	# either vertically or horizontally.
	# Will temporarily modify the "overflow" style to detect this
	# if necessary.
	checkOverflow: (el)->
		curOverflow = el.style.overflow

		if ( !curOverflow || curOverflow == "visible" )
			el.style.overflow = "hidden"
		isOverflowing = el.clientWidth + 10 < el.scrollWidth  || el.clientHeight + 10 < el.scrollHeight
		el.style.overflow = curOverflow
		isOverflowing

	#  called when we drop a photo on day view
	onDrop:(event, ui)->
		that = @
		recipient = $(".hoverActive")
		recipient.removeClass "hoverActive"
		if @sortedItemIndex == ui.item.index() && recipient.is(@sortedDayFrom) then return

		# form the new date
		id = ui.item.attr("data-id") | ui.item.find(".image").attr("data-id")
		nextPhotoTime = ui.item.next().find(".time").text()
		prevPhotoTime = ui.item.prev().find(".time").text()
		recipientDay = if (recipient.parent().attr("data-date")) then Date.parse(recipient.parent().attr("data-date")) else @stack.date

		if nextPhotoTime
			nextPhotoDate = recipientDay.set({
				hour:Date.parse(nextPhotoTime).getHours()
				minute:Date.parse(nextPhotoTime).getMinutes()
			})
			datePhoto = nextPhotoDate.add(-1).minutes()
		else if prevPhotoTime
			prevPhotoDate = recipientDay.set({
				hour:Date.parse(prevPhotoTime).getHours()
				minute:Date.parse(prevPhotoTime).getMinutes()
			})
			datePhoto = prevPhotoDate.add(+1).minutes()
		else
			timeVal = ui.item.find(".time").text()
			time = Date.parse(timeVal, 'hh:mm tt')
			datePhoto = recipientDay.set({
				hour:time.getHours(),
				minute:time.getMinutes()
			})

		if datePhoto
			@load()
			if @copyItem
				# create new photo
				$.ajax({
					type: "POST",
					url: '/data_points.json',
					success: () ->
						that.stack.onSuccessAjax()
					data:
						data_point : {
							id: id,
							uploaded_at: UTIL.prepareForServer(datePhoto)
						},
						dataType: 'json'
				})
			else
				# update date
				$.ajax({
					type: "PUT",
					url: '/data_points/'+id+'.json',
					success: () ->
						that.stack.onSuccessAjax()
					data:
						data_point : {
							id: id,
							uploaded_at: UTIL.prepareForServer(datePhoto)
						},
						dataType: 'json'
				})

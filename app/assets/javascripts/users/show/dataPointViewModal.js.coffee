class foodrubix.DataPointViewModal	extends Spine.Controller

	elements:
		".btn-comment":"btnComment"
		".btn-like":"btnLike"
		".input-comment":"inputComment"
		".control-group.comment": "divTextarea"
		".nbLikes": "nbLikesHTML"
		".nbComments": "nbCommentsHTML"
		".unlike": "unlike"

	events:
		"click .btn-like": "like"
		"click .unlike": "unlike"
		"click .btn-comment" : "comment"
		"keypress textarea" : "onEnter"

	constructor: ()->
		super
	
	init: () ->
		@id = @el.attr('data-id')
		@userId = @master.el.attr("data-user")
		@nbLikes = parseInt(@nbLikesHTML.text())
		@nbComments = parseInt(@nbCommentsHTML.text())
		@refreshComments()
		@refreshLike()
		
	refreshLike: () =>
		$.ajax({
			type: "GET"
			url: '/likes'
			dataType: 'json'
			data: 
				data_point_id: @id
				user_id: @userId
			success: @ongetLikeState.bind @
		})
	
	ongetLikeState: (data) =>
		if data.length
			@likeId = data[0].id
			@changeLikeState("Liked")
			

	refreshComments: () =>
		$.ajax({
			type: "GET"
			url: '/comments'
			dataType: 'script'
			data: 
				data_point_id: @id
		})
		
	onEnter: (e) =>
		
		if e.keyCode == 13  #enter
			@comment()
			return false
		
	comment: () =>
		
		if @divTextarea.hasClass("hide")
			@divTextarea.removeClass("hide")
			@divTextarea.find("textarea").focus()
		else
			text = @inputComment.val()
			if text != ""
				@el.find(".control-group.comment").removeClass('error')
				@el.find('.help-inline.comment').addClass('hide')
				@btnComment.button('loading')	
				data = 
					user_id: @userId
					text: text
					data_point_id: @id
				$.ajax({
					type: "POST"
					url: '/comments.json'
					success: @onSuccessComment.bind @
					dataType: 'json'
					data: 
						comment : data
				})
			else
				# display error message
				@el.find(".control-group.comment").addClass('error')
				@el.find('.help-inline.comment').removeClass('hide')
		
	
	onSuccessComment: (data, textStatus, jqXHR) =>
		@btnComment.button('reset')	
		@inputComment.val("")
		@divTextarea.addClass("hide")
		@nbComments = @nbComments+1
		@nbCommentsHTML.html(@nbComments)
		@updateMasterInfo("comments")
		@refreshComments()
		
	updateMasterInfo: (which) =>
		if which == "comments"
			@master.el.find("#image_"+@id+ " span.nbComments").html(@nbComments)
		else if which == "likes"
			@master.el.find("#image_"+@id+ " span.nbLikes").html(@nbLikes)
	
	like: () =>
		data = 
			user_id: @userId
			data_point_id: @id
		$.ajax({
			type: "POST"
			url: '/likes.json'
			success: @onSuccessLike.bind @
			dataType: 'json'
			data: 
				like : data
		})
	
	onSuccessLike: (data, textStatus, jqXHR) =>
		@likeId = data.id
		@nbLikes = @nbLikes+1
		@nbLikesHTML.html(@nbLikes)
		@updateMasterInfo("likes")
		@changeLikeState("Liked")
	
	changeLikeState: (text) =>
		@btnLike.toggleClass("disabled").find("span").html(" "+ text)
		@unlike.toggleClass("hide")
	
	unlike: ()=>		
		likeId = @likeId
		$.ajax({
			type: "DELETE"
			url: '/likes/'+likeId+'.json'
			success: @onSuccessUnlike.bind @
			dataType: 'json'
		})

	onSuccessUnlike: (data, textStatus, jqXHR) =>
		@nbLikes = @nbLikes - 1
		@nbLikesHTML.html(@nbLikes)
		@updateMasterInfo("likes")
		@changeLikeState("Like")
				
window.UTIL = {
	exec: (controller, action) ->	
		ns = window.foodrubix
		action = if action == undefined then "init" else action
		if ( controller != "" && ns[controller] && typeof ns[controller][action] == "function" ) 
			ns[controller][action]()

	init: () ->
		body = document.body
		controller = body.getAttribute "data-controller" 
		action = body.getAttribute "data-action"
		UTIL.exec "common"  #run common.init
		UTIL.exec controller #run controller.init
		UTIL.exec controller, action #run controller.action
	
	load: (elmt, classname, show) ->
		elmt.empty()
		if show
			elmt.html(Mustache.render($('#loading_tmpl').html(), {class:classname}))
		else
			$('.loading.'+classname).remove()

}

$( document ).ready UTIL.init

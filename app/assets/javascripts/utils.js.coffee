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


	#
	# 	  @name encodeBase64
	# 	  @param {String} input the string to encode
	# 	  @return {String} base64 encoded string
	#
	encodeBase64: (input) ->
		chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='

		result = ''
		i = 0

		while (i < input.length)
			chr1 = input.charCodeAt(i++)
			chr2 = input.charCodeAt(i++)
			chr3 = input.charCodeAt(i++)

			enc1 = chr1 >> 2
			enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
			enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
			enc4 = chr3 & 63

			if (isNaN(chr2))
				enc3 = enc4 = 64
			else if (isNaN(chr3))
				enc4 = 64

			result += chars.charAt(enc1) + chars.charAt(enc2) + chars.charAt(enc3) + chars.charAt(enc4)
		result

}

$( document ).ready UTIL.init

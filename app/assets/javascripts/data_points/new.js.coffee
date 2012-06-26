foodrubix.data_points.new = () ->
	data_point_uploader = new dataPointUploader({el: $(".container")})
	

class dataPointUploader extends Spine.Controller
	
	events:
		"click .upload": "upload"

	elements:
		".form-horizontal": "form"

	constructor: ()->
		super

	upload: (e) =>
		$(e.target).button('loading')
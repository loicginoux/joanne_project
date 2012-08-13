class foodrubix.SettingsPictureController extends Spine.Controller
	events:
		"click .btn-upload": "changePhoto"
		"change .user_picture": "onChangePhoto"

	elements:
		".user_picture":       "fileInput"
		

	constructor: ()->
		super		

	changePhoto: (e) =>
		@fileInput.click()
		e.stopPropagation()
		e.preventDefault()
		return false


	onChangePhoto: (e) =>
		input = e.target
		if input.files && input.files[0]
			reader = new FileReader()
			reader.onload = (e) ->
				$(input).parent().find("img").attr('src', e.target.result).parent().css("height", "auto");
			reader.readAsDataURL(input.files[0]);	

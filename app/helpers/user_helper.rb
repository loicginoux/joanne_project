module UserHelper
	def getPicture(user, size = 'medium')
		link_to image_tag(user.picture.url(size)) ,  user_path(:username=> user.username), :class=>"user_pic"
	end

	def getUsername(user, className = "")
		link_to user.username, user_path(:username=> user.username), :class=>"username "+className
	end

	def getOffset(user)
		Time.zone = user.timezone
    offset = Time.zone.now.utc_offset
    Time.zone = Rails.application.config.time_zone
		return offset
	end

end

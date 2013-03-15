module UserHelper
	def getPicture(user, size = 'medium', style = "50px")
		link_to image_tag(user.pic().url(size), :width => style, :height => style) ,  user_path(:username=> user.username), :class=>"user_pic"
	end

	def getUsername(user, className = "")
		link_to user.username, user_path(:username=> user.username), :class=>"username "+className
	end
end

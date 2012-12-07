module UserHelper
	def getPicture(user, size = 'medium')
		link_to image_tag(user.picture.url(size)) ,  user_path(:username=> user.username), :class=>"user_pic"
	end

	def getUsername(user)
		link_to user.username, user_path(:username=> user.username), :class=>"username"
	end


end

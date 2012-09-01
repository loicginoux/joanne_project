module UserHelper
  def getPicture(user)
      size = 200
      link_to image_tag(user.picture.url(:medium), :size => size) ,  user_path(:username=> user.username)
  end
  
  def getUsername(user)
      link_to user.username, user_path(:username=> user.username)
  end
end

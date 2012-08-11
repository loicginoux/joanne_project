module UserHelper
  def getPicture(user)
      size = 200
      logger.debug "user pic"      
      logger.debug user.picture.file?      

        image_tag user.picture.url(:medium), :size => size

  end
end

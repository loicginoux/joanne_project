module UserHelper
  def getPicture(user)
      size = 200
      image_tag user.picture.url(:medium), :size => size

  end
end

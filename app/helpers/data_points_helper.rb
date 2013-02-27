module DataPointsHelper
  def getPhoto(data_point, size)
 	award = "Hot Photo" if data_point.hot_photo_award
 	award = "Smart Choice" if data_point.smart_choice_award
  	ribbon = award ? '<div class="ribbon-wrapper right"><div class="ribbon"><span>'+award+'</span></div></div>' : ""
    image = image_tag(data_point.photo.url(size))
  	img_html = '<div class="img_wrapper">'+ ribbon + image+'</div>'
  	raw(img_html)
  end

end



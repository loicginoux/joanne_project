module DataPointsHelper
  def getPhoto(data_point, size)
      return image_tag "http://s3.amazonaws.com/"+S3_CREDENTIALS[:bucket]+"/photos/"+data_point.id.to_s+"/"+size+".jpg"
  end

end



module CommentsHelper
	def sanitize(text)
		RedCloth.new( ActionController::Base.helpers.sanitize( comment.text ), [:filter_html, :filter_styles, :filter_classes, :filter_ids] ).to_html
	end
end

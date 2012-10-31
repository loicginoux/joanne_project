class PagesController < HighVoltage::PagesController
  layout :layout_for_page

  protected
    def layout_for_page
    	logger.debug ">>>>>>>>>>>>>"
    	logger.debug params[:id]
      case params[:id]
      when 'home'
        'home'
      else
        'application'
      end
    end
end

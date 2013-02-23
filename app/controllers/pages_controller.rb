class PagesController < HighVoltage::PagesController
  layout :layout_for_page

  caches_action :show, :layout => false, :cache_path => Proc.new { |c| c.params }

  protected
    def layout_for_page
      case params[:id]
      when 'home'
        'home'
      when 'terms_of_services'
        'home'
      when 'privacy'
        'home'
      when "fileInputForm"
        'empty'
      else
        'application'
      end
    end
end

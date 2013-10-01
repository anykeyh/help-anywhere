class HelpAnywhere::HelpAnywhereController < HelpAnywhere::BaseController
  def routes
    render :json => HelpAnywhere.config.routes
  end
end
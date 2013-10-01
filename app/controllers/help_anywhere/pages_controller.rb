class HelpAnywhere::PagesController < HelpAnywhere::BaseController
  def create
    page = HelpAnywhere::Page.new
    page.resource = HelpAnywhere::Resource.find_by_id params[:resource_id]

    if page.save
      render :json => {
        :id => page.id,
        :order => page.number
      }
    else
      render :json => { :status => "BAD", :errors => page.errors }
    end
  end

  def show
    page = HelpAnywhere::Page.find_by_id params[:page_id]

    if resource.nil?
      render :json => nil
    else
      render :json => {
        :id => page.id,
        :order => page.number,
        :items => page.items
      }
    end
  end

end
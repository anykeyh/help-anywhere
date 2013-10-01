class HelpAnywhere::ResourcesController < HelpAnywhere::BaseController
  def show
    resource = HelpAnywhere::Resource.find_by_name params[:name]

    if resource.nil?
      render :json => {
        :pages => []
      }
    else
      render :json => {
        :pages => resource.pages.order('number ASC').map{ |x|
          {
            :order => x.number,
            :items => x.items.map{ |x|
              { :id => x.id, :class_id => x.class_id, :content => JSON.parse(x.content || '{}') }
            }
          }
        }
      }
    end
  end

  def save
    resource = HelpAnywhere::Resource.find_by_name params[:name]

    if resource.nil?
      resource = HelpAnywhere::Resource.new
      resource.name = params[:name]
      resource.save!
    end

    page_list = JSON.parse(params[:content])

    resource.transaction do
      resource.pages.each do |page_to_remove|
        page_to_remove.destroy
      end

      page_list.each do |page|
        page = page.with_indifferent_access
        page_model = HelpAnywhere::Page.new
        page_model.resource = resource
        page_model.save!

        page[:items].each do |item|
          it = HelpAnywhere::Item.new

          it.class_id = item[:class_id]
          it.content = item[:content].to_json
          it.page = page_model

          it.save!
        end

        page_model.save!
      end
    end

    render :json => {status: 'OK'}
  end

  def create
    resource = HelpAnywhere::Resource.new
    resource.name = params[:name]

    if resource.save
      render :json => {
        :pages => resource.pages.map{ |x|
          {
            :order => x.number,
            :items => x.items
          }
        }
      }
    else
      render :json => { :status => "BAD", :errors => resource.errors }
    end

  end

  def delete
    resource = HelpAnywhere::Resource.find params[:name]
    resource.destroy!
  end

end

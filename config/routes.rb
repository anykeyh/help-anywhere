Rails.application.routes.draw do
  namespace :help_anywhere do
    match "resources" => "resources#show"
    match "resources/create" => "resources#create", :via => :get
    match "resources/save" => "resources#save"

    match "pages/:page_id" => "pages#show"

    match "routes" => "help_anywhere#routes", :via => :get
  end
end
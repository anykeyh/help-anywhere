class HelpAnywhere::BaseController < ApplicationController
  before_filter :check_authentication, :only => [:edit, :create, :new, :delete, :save]

private
  def check_authentication
    unless HelpAnywhere.config.has_edition_role? self
      render :text => "You are not authorized to edit help", :status => 403
      return
    end
  end
end
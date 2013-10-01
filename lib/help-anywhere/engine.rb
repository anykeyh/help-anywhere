require "rails"

module HelpAnywhere
  class Engine < Rails::Engine
    engine_name :help_anywhere
    #initializer "add assets to precompile" do |app|
       #app.config.assets.precompile += %w( master/master.js master.css )
    #end
  end
end
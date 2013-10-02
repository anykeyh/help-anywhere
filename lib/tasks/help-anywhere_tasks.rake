#coding: utf-8
require 'colorize'

namespace :help_anywhere do
  desc "Generate everything you need to run help-anywhere plugin."
  task :setup => ['help_anywhere:install:migrations'] do

    relpath = File.join ["config", "initializers", "help_anywhere.rb"]

    filepath = File.join Dir.pwd, relpath

    if File.exists?(filepath)
      puts "[X] ".white + "Skipping `#{relpath}`: File already exists".yellow
    else
      File.write filepath,
<<-RUBY
HelpAnywhere.configure do |config|

  config.routes do |routes|
    # Configure route between help pages and your controllers
    # Use `*` to wilcard a path level, `...` to wilcard everything after
    # and `?` to reuse a path level
    # The second string is just an unique id for your help, you can use
    # whatever you want!
    #
    # Example:
    #
    # routes.match '/articles/*/show...', 'article_show'
    # routes.match '/admin/?/*/?...', 'admin_help_for_resource_$1_action_$2'
  end

  # Set here the method which is called to allow or disallow edition mode
  # You can create this method in your ApplicationController class.
  # Default is a method which return always true: every one can edit help.
  #
  # config.edition_role = :can_user_edit_help?
end
RUBY

      puts "[»]".white + " create `#{relpath}`".green
    end

    puts "[»]".white + "Done! please add `require help_anywhere` in both application.js and application.css, run migrations, enjoy!".green
  end
end
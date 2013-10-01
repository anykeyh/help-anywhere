= Help Anywhere

This plugin for rails provides a powerful help system for every websites
built with ruby on rails.

Users can read the help, and administrator can update help pages.

You can select on or more elements in your website,
add help box on it, save it, create "step by step" help page.

== Usage

Add in your Gemfile:


    gem 'help-anywhere'


Then


    bundle install
    rake help-anywhere:install:migrations
    rake help-anywhere:setup
    rake db:migrate


Finish by setup css and javascript files in your application.js/css:

    //= require help_anywhere


That's all!

Finally, update the file `config/help-anywhere.rb` to change the permission strategy and the help routes!
See help-anywhere-example project for more information!

Log-in has edit mode, and create new help page with our editor. Enjoy!

== Version

0.11

- HelpAnywhere is provided with Bubble component, but you can also build your own. Check `bubble.coffee.js`
for more informations
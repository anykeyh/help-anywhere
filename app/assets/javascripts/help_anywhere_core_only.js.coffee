#
# This is the entry point for help_anywhere plugin
#
#
#= require help_anywhere/help_anywhere
#= require help_anywhere/help_anywhere_editor
#= require help_anywhere/components/component
jQuery ($) ->
  $.get('/help_anywhere/routes').success (data)->
    HelpAnywhere.add_routes(data)
    HelpAnywhere.render()
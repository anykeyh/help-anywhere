#TODO
jQuery ($) ->

  current_mouse_move_target = null

  $('html, body').mousemove (evt) ->
    return unless HelpAnywhereEditor.hook_enabled

    $(current_mouse_move_target).removeClass('ha-hover')

    id = $(evt.target).attr('id')

    if id? and id isnt ''
      $(evt.target).addClass('ha-hover')
      current_mouse_move_target = evt.target
    else
      nearest_identifiable = do ->
        parents = $(evt.target).parents()
        for ancestor in parents
          ancestor_id = $(ancestor).attr('id')
          if ancestor_id? and id isnt ''
            return ancestor
        return null

  $('html, body').click (evt) ->
    return unless HelpAnywhereEditor.hook_enabled



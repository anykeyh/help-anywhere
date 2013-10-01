do($ = jQuery) ->
  current_mouse_move_target = null
  hook_enabled = true

  HelpAnywhereEditor =
    focus: (elm) ->
      @focused?.blur?()
      @focused = elm
    render: ->
      @hook()
    hook: ->
      @hook_mouse_move()
      @hook_mouse_click()
    hook_mouse_move: ->
      $('body').mousemove (evt) ->
        return unless hook_enabled

        $(current_mouse_move_target).removeClass('ha-hover')

        id = $(evt.target).attr('id')

        if id? and id isnt ''
          $(evt.target).addClass('ha-hover')
          current_mouse_move_target = evt.target
        else
          nearest_identifiable = do ->
            parents = $(evt.target).parents()
            console.log parents.toArray().map((x) -> $(x).attr('id')).join(', ')
            for ancestor in parents
              ancestor_id = $(ancestor).attr('id')
              if ancestor_id? and id isnt ''
                return ancestor
            return null
          $(nearest_identifiable).addClass('ha-hover')
          current_mouse_move_target = nearest_identifiable

    hook_mouse_click: ->
      $('body').mousemove (evt) ->
        return unless hook_enabled

  window.HelpAnywhereEditor = HelpAnywhereEditor
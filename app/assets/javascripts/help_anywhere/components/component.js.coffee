do($=jQuery) ->
  class window.HelpAnywhere.Component
    @register: (class_name, class_obj) -> HelpAnywhere.components[class_name] = class_obj

    @_NEED_IMPLEMENTATION: (function_name) -> 
      @::[function_name] = ->
        console.log "call of #{function_name}"
        throw new Error("You must implement #{function_name}")

    @_NEED_IMPLEMENTATION('build')
    @_NEED_IMPLEMENTATION('getData')
    @_NEED_IMPLEMENTATION('blur')

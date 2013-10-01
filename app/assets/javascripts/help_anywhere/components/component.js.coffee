do($=jQuery) ->
  class window.HelpAnywhere.Component
    @register: (class_name, class_obj) -> HelpAnywhere.components[class_name] = class_obj

    @_NEED_IMPLEMENTATION: (function_names...) ->
      for function_name in function_names
        @::[function_name] = ->
          throw new Error("You must implement #{function_name}")

    @_NEED_IMPLEMENTATION 'build', 'getData', 'blur', 'remove'

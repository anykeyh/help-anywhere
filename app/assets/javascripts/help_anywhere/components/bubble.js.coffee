###
  help-anywhere's bubble text content.

  This is for now the only component bundled with the project.
  It looks like a comic book bubble.

  You can take as example for new components.
  Here we code all logic for show and edit mode.
###
do ( $ = jQuery ) ->

  getAbsoluteSelectorFor = (elm) ->
    if (id = elm.attr('id'))?
      return "##{id}"

    console.log elm.parents().toArray()

    selector = elm.parents().toArray()
    .map (x) ->
      out = x.tagName
      if (id = $(x).attr('id'))?
        out += "##{id}"
      if (classes = $(x).attr('class'))? and classes isnt ''
        out += '.' + classes.split(/\s/g).join('.')
      return out
    .reverse()
    .join('>')

    selector  +=  ">:nth-child(#{elm.index()+1})"

    return selector

  window.HookingSystem =
    currentMouseMoveTarget: null
    enabled: false

    callback: (selector) -> console.log selector

    enable: (callback) ->
      $("#help-anywhere-layout").css display: 'none'

      @callback = callback
      @enabled = true


  handleMouseClick = (evt) ->
    return unless HookingSystem.enabled

    evt.preventDefault()
    evt.stopPropagation()

    $(evt.target).removeClass('ha-hook-hover')
    $(HookingSystem.currentMouseMoveTarget).removeClass("ha-hook-hover")

    HookingSystem.callback(getAbsoluteSelectorFor($(evt.target)))
    HookingSystem.enabled = false

    $("#help-anywhere-layout").css display: 'block'

  handleMouseMove = (evt) ->
    return false unless HookingSystem.enabled

    $(HookingSystem.currentMouseMoveTarget).removeClass('ha-hook-hover').off('click', handleMouseClick)

    $(evt.target).addClass('ha-hook-hover').on('click', handleMouseClick)

    HookingSystem.currentMouseMoveTarget = evt.target

  $("html").on 'mousemove', handleMouseMove

  BUBBLE_TEMPLATE = -> """
    <div class="ha-bubble-box">
      <div class="ha-bubble-pointer"></div>
      <div class="ha-bubble-content">#{@content}</div>
    </div>
  """

  ANCHOR_TEMPLATE = (position) -> """
    <div class="ha-bubble-anchor #{@position}">"
  """

  EDIT_TEMPLATE = -> """
    <div class="ha-bubble-edit-box">
      Position:
      <select class="ha-bubble-position">
        <option value="free">Free</option>
        <option value="left">Left</option>
        <option value="top">Top</option>
        <option value="right">Right</option>
        <option value="bottom">Bottom</option>
        <option value="guess">Auto</option>
      </select>
      Selector:
      <input type="text" class="ha-bubble-selector" value=""><div class="ha-bubble-select-selector">*</div>
      <input type="button" class="ha-bubble-remove btn btn-danger" value="Remove">
    </div>
  """

  # Just constants to get named into array for d&d of resize handling
  X = 0
  Y = 1
  LEFT = 0
  TOP = 1
  WIDTH = 2
  HEIGHT = 3

  class Bubble extends window.HelpAnywhere.Component
    constructor: ->
      @content = "Add text here"
      @drag =
        hasStarted: no
        startOffset: [0,0]
        startCoords: [0,0,0,0]

    load: (data) ->
      $.extend this, data

    build: (editMode) ->
      @elm = $(BUBBLE_TEMPLATE.call(this))

      @editMode = editMode

      #Render the handlers for edition mode as needed
      @buildEditMode() if editMode

      @elm.addClass(@htmlClass) if @htmlClass?

      #Temporary append to body to check the size.
      $('body').append(@elm)

      #Focusing element
      if @editMode
        @elm.on 'click', (evt) =>
          @refresh()

          evt.stopPropagation()

          HelpAnywhereEditor.focus(this)

          for k,anchor of @anchors
            anchor.css display: 'block'

          @control.css display: 'block'

          if @isBinded()
            @anchors.x.css display: 'none'

      return @refresh()

    isBinded: ->
      @target and $(@target).length > 0 and @position isnt 'free'

    blur: ->
      @control.css display: 'none'

      for k,anchor of @anchors
        anchor.css display: 'none'

    refresh: ->
      @elm.css(height: @height) if @height!=null

      @targetArea ?= $("<div class='ha-bubble-target-selected'>")

      #We set a default width if no width is set, to avoid some render problem
      if @width?
        @elm.css(width: @width)
      else
        @elm.css(width: '150px')

      if @isBinded()
        pos = $(@target).first().offset()

        objectSize   = [$(@target).outerWidth(), $(@target).outerHeight()]
        documentSize = [$("body").outerWidth(), $("body").outerHeight()]
        bubbleSize = [@elm.outerWidth(), @elm.outerHeight()]

        boundingBox =
          x: parseFloat(pos.left)
          y: parseFloat(pos.top)
          w: parseFloat(objectSize[0])
          h: parseFloat(objectSize[1])

        boundingBox.x2 = boundingBox.x + boundingBox.w
        boundingBox.y2 = boundingBox.y + boundingBox.h

        docW = parseFloat(documentSize[0])
        docH = parseFloat(documentSize[1])

        unless @position || @position is 'guess' #Guess mode
          ###
            x,y-------x2,y
            |          |
            |          |
            |          |
            x,y2-----x2,y2
          ###
          leftSpace = boundingBox.x
          rightSpace = docW - boundingBox.x2

          topSpace = boundingBox.y
          bottomSpace = docH - boundingBox.y2

          values = right: rightSpace, top: topSpace, bottom: bottomSpace

          selectedPosition = 'left'
          selectedValue = leftSpace
          for k,v of values
            if v > selectedValue
              selectedValue = v
              selectedPosition = k

          finalPosition = selectedPosition
        else
          finalPosition = @position

        switch finalPosition
          when 'top'
            @elm.css
              top: (boundingBox.y - bubbleSize[1]) + "px"
              left: boundingBox.x + Math.round((boundingBox.w-bubbleSize[0])/2) + "px"
              'margin-top': '-14px'
              'margin-left': '0px'
          when 'bottom'
            @elm.css
              top: boundingBox.y2 + "px"
              left: boundingBox.x + Math.round((boundingBox.w-bubbleSize[0])/2) + "px"
              'margin-top': '14px'
              'margin-left': '0px'
          when 'right'
            @elm.css
              top: boundingBox.y + Math.round((boundingBox.h-bubbleSize[1])/2) + "px"
              left: boundingBox.x2 + "px"
              'margin-left': '14px'
              'margin-top': '0px'
          else
            @position = 'left'
            @elm.css
              top: boundingBox.y + Math.round((boundingBox.h-bubbleSize[1])/2) + "px"
              left: (boundingBox.x - bubbleSize[0]) + "px"
              'margin-left': '-14px'
              'margin-top': '0px'

        #reset all pointer-* class and set the good one.
        @elm.find('.ha-bubble-pointer').attr(class: 'ha-bubble-pointer').addClass("pointer-#{finalPosition}")

        if @editMode
          if @target
            @control.find('.ha-bubble-position').val(@position || 'guess')
          else
            @control.find('.ha-bubble-position').val('free')

          @control.find('.ha-bubble-selector').val(@target)

        @elm.find('.ha-bubble-pointer').css display: 'block'

        @targetArea.css
          width: $(@target).outerWidth()
          height: $(@target).outerHeight()
          top: boundingBox.y
          left: boundingBox.x
          display: 'block'
      else
        @elm.css top: "#{@y}px", left: "#{@x}px"
        @elm.find('.ha-bubble-pointer').css display: 'none'
        @targetArea.css display: 'none'

      return [@elm, @targetArea]

    saveChanges: ->
      HelpAnywhere.saveElement this


    getData: ->
      x: @x
      y: @y
      position: @position
      width: @width
      height: @height
      target: @target
      content: @content

    ###
      DRAG HANDLING
    ###
    handleMouseMove: (evt) ->
      return unless @drag.hasStarted

      drag_anchor = @drag.currentAnchor

      decal = [
        @drag.startOffset[X]-evt.pageX
        @drag.startOffset[Y]-evt.pageY
      ]

      coords = [].concat @drag.startCoords

      if ~drag_anchor.indexOf('x')
        coords[LEFT] -= decal[X]
        coords[TOP] -= decal[Y]
      else
        if ~drag_anchor.indexOf('n')
          coords[TOP] -= decal[Y]
          coords[HEIGHT] += decal[Y]
        else if ~drag_anchor.indexOf('s')
          coords[HEIGHT] -= decal[Y]

        if ~drag_anchor.indexOf('e')
          coords[WIDTH] -= decal[X]
        else if ~drag_anchor.indexOf('w')
          coords[LEFT] -= decal[X]
          coords[WIDTH] += decal[X]

      @x = coords[LEFT]
      @y = coords[TOP]
      @width = coords[WIDTH]
      @height = coords[HEIGHT]

      @refresh()

    handleMouseUp: ->
      if @drag.hasStarted
        @drag.hasStarted = no
        @saveChanges()

    handleMouseDown: (evt) ->
      @drag.hasStarted = yes

      @drag.currentAnchor = $(evt.target).data('_position')

      @drag.startOffset = [
        evt.pageX
        evt.pageY
      ]

      @drag.startCoords = [
        @elm.position().left
        @elm.position().top
        @elm.width()
        @elm.height()
      ]

    handleAnchorBehavior: (anchor) ->
      drag_anchor = anchor.data('_position')

      @handleMouseMoveInstance = @handleMouseMove.bind(this)
      @handleMouseUpInstance = @handleMouseUp.bind(this)

      $('body')
      .on('mousemove', @handleMouseMoveInstance)
      .on('mouseup', @handleMouseUpInstance)

      anchor.on 'mousedown', @handleMouseDown.bind(this)

    ###
      END OF DRAG HANDLING
    ###

    remove: ->
      $('body')
      .off('mousemove', @handleMouseMoveInstance)
      .off('mouseup', @handleMouseUpInstance)

      @elm.remove()

    buildEditMode:  ->
      self = this
      @anchors = {}

      for position in ['ne', 'n', 'nw', 'w', 'sw', 's', 'se', 'e', 'x']
        anchor = @anchors[position] = $("<div class='ha-bubble-anchor #{position}'>")
        anchor.data('_position', position)

        @elm.append anchor
        @handleAnchorBehavior anchor

      @control =  $(EDIT_TEMPLATE()).appendTo(@elm)

      @control.find('.ha-bubble-position').on 'change', ->
        self.position = $(this).val()
        self.saveChanges()
        self.refresh()

      @control.find('.ha-bubble-selector').on 'change', ->
        self.target = $(this).val()
        self.saveChanges()
        self.refresh()

      @control.find('.ha-bubble-remove').on 'click', ->
        HelpAnywhere.deleteItem(self)

      @control.find('.ha-bubble-select-selector').on 'click', ->
        HookingSystem.enable (selector) ->
          self.position = 'auto' if self.position is 'free'
          self.control.find('.ha-bubble-selector').val(selector).trigger('change')


      content = @elm.find('.ha-bubble-content')

      content
      .attr('contenteditable', true)
      .on 'focus', =>
        # This test is a special case when user change focus from browser
        if !content.data('_has_focus')
          content.data('_has_focus', true)
          #Get the html:
          escapedHtml = content.text(content.html()).html()
          #Replace the <br> by "\n"
          # And &amp; by & (for &nbsp; for example)
          escapedHtml = escapedHtml
          .replace(/&lt;br&gt;/g, "<br>")
          .replace(/&amp;/g, "&")
          # Render the html, but keep the <br> correctly rendered
          content.html(escapedHtml)
      .on 'blur', =>
        # This test is a special case when user change focus from browser
        if content.data('_has_focus')
          content.data('_has_focus', false)
          content.html(
            content.html()
            .replace(/(<div>)(((?!<\/div>).)*)(<\/div>)/g, "<br>$2")
            # We ignore the <br> before a markup
            .replace(/<br>&lt;/g, '&nbsp;&lt;')
            .replace(/&lt;/g, "<")
            .replace(/&gt;/g, ">")
            .replace(/&nbsp;/g, " ")
            .replace("/&amp;/g", "&")
          )
          @content = content.html()

        @saveChanges()

  #Register generator to generators list
  HelpAnywhere.Component.register('Bubble', Bubble)



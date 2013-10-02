do($ = jQuery) ->
  HELP_TEMPLATE = (args) ->
    """
      <div id="help-anywhere-widget" title="Help">?
      </div>
    """

  HELP_INTERFACE_TEMPLATE = (pages, edit_mode) ->
    """
      <div id="help-anywhere-layout">
        <div class="ha-page-content"></div>
        #{
        if edit_mode
          HELP_INTERFACE_EDIT_MODE(pages)
        else ''
        }
      </div>
    """

  HELP_INTERFACE_EDIT_MODE = (pages) ->
    """
      <div class="ha-edit-bottom-layout">
        <div class="ha-new-component">
          Add component:
            <select class="ha-add-component">
            #{HELP_SELECT_COMPONENT()}
            </select>
            <input type="button" class="ha-save-btn btn btn-primary" value="Save"></input>
            <input type="button" class="ha-remove-page-btn btn btn-danger" value="Remove page"></input>
            <input type="button" class="ha-exit-btn btn btn-danger" value="Exit"></input>
        </div>
        <div class="ha-page-list">
          #{HELP_INTERFACE_PAGES(pages)}
        </div>
      </div>
    """

  HELP_SELECT_COMPONENT = ->
    "<option value='' selected='selected'>Select a component</option>" + (
      for k,v of HelpAnywhere.components
        "<option value='#{k}'>#{k}</option>"
    ).join("")

  HELP_INTERFACE_PAGES = (pages) ->
    (for page, idx in pages
      HELP_INTERFACE_PAGE(idx) ).join('') +
    """
      <div class="ha-new-page">+</div>
    """

  HELP_INTERFACE_PAGE = (idx) -> """<div class="ha-page" data-idx="#{idx}">#{idx}</div>"""

  class HelpAnywhere
    @API_URL: "/help_anywhere"

    @render: ->
      @instance = new HelpAnywhere
      @instance.init()
    @show: (edit_mode=false) ->
      if @instance
        @instance.openHelpInterface(edit_mode)
        return true
      else
        return false
    @hide: -> @instance.closeHelpInterface()
    @edit: -> @show(yes)

    @saveElement: (elm) ->
      for p in @instance.pageList
        for e, idx in p.items
          if e.id is elm.id
            @instance.elementsChanged = true
            p.items[idx].content = elm.getData()
            return

    @addRoutes: (routes) ->
      @routes = (@routes ? [])

      if not routes instanceof Array
        routes = [routes]

      for [regexp, value] in routes
        regexp = '^' +
          regexp
          .replace(/\//g, '\\/')
          .replace(/\./g, '\\.')
          .replace(/\*/g, '[^\\/]*')
          .replace(/\.\.\./g, '.*') #/[\.]{3}/ ??
          .replace(/\?\?/g, '(.*)')
          .replace(/\?/, '([^\\/]*)') + '$'
        @routes.push [new RegExp(regexp), value]

    @deleteItem: (elm) ->
      for p in @instance.pageList
        for e, idx in p.items
          if e.id is elm.id
            p.items.splice(idx, 1)
            elm.remove()
            return true

    selectRoute: (path) ->
      for [regexp, value] in HelpAnywhere.routes
        return path.replace(regexp, value) if regexp.test(path)

      return false

    elementsChanged: false

    init: ->
      @fixBody()
      @retrieveResource()

    fixBody: ->
      $("body").css
        position: "absolute"
        left: 0
        top: 0
        "min-width": "100%"
        "min-height": "100%"
        margin: 0

    buildInterface: ->
      unless @help?
        @help = $(HELP_TEMPLATE())
        @help.on 'click', => @openHelpInterface()
      @help.css(display: 'block', opacity: '0')
        .animate(opacity: '1', 2000)
        .appendTo($('body'))

    showPage: (pageIndex) ->
      return unless @pageList[pageIndex]?

      @helpInterface.find('.ha-page-content').empty()

      @helpInterface.find('.ha-page').removeClass('selected')
      @helpInterface.find(".ha-page:nth-child(#{Number(pageIndex)+1})").addClass('selected')

      @currentPage = pageIndex

      items = @pageList[pageIndex].items

      for item in items
        g = new HelpAnywhere.components[item.class_id]()
        g.id = item.id
        g.class_id = item.class_id
        g.load(item.content)

        @helpInterface.find('.ha-page-content').append(g.build(@edit_mode))

    movePage: (fromIndex, toIndex) ->
      #Magic coffee <3
      [@pageList[fromIndex], @pageList[toIndex]] = [@pageList[toIndex], @pageList[fromIndex]]
      @currentPage = toIndex
      @showPage(@currentPage) #Refreshing interface for edition mode


    deletePage: ->
      pageIndex = Number(@helpInterface.find('.ha-page.selected').remove().attr('data-idx'))
      @pageList.splice(pageIndex, 1)

      #Refreshing the indices
      for page, idx in @helpInterface.find('.ha-page')
        $(page).text(idx).attr('data-idx', idx)

      @currentPage = pageIndex - 1

      if @currentPage < 0
        @currentPage = 0

      if @pageList.length > 0
        @showPage(@currentPage)

    createNewPage: ->
      if @pageList.length == 0
        @pageList.push items: [], number: 0
      else
        @pageList.push items: [], number: @pageList[@pageList.length-1].number+1

      newPage = $(HELP_INTERFACE_PAGE(@pageList.length-1))
      newPage.insertBefore(@helpInterface.find('.ha-new-page'))
      newPage.on 'click', =>
        @currentPage = newPage.attr('data-idx')
        @showPage(@currentPage)
      @showPage(newPage.attr('data-idx'))

    temporaryId: (pageIndex) ->
      @_uid ?= 0
      return "_#{@_uid++}" #Temporary ids are discriminated by adding underscore before.

    createNewComponent: (pageIndex, componentClass) ->
      if componentClass? and componentClass isnt ''
        component = new HelpAnywhere.components[componentClass]()
        @helpInterface.find('.ha-page-content').append(component.build(@edit_mode))

        component.class_id = componentClass
        component.id = @temporaryId()

        @pageList[pageIndex].items.push {id: component.id, class_id: componentClass}
    closeHelpInterface: ->
      if @elementsChanged
        return unless confirm("Are you sure? All changes will be losts...")
      @helpInterface.remove()
      @helpInterface = null

    openHelpInterface: (@edit_mode=false)->
      return if @helpInterface?

      @helpInterface = $ HELP_INTERFACE_TEMPLATE(@pageList, @edit_mode)
      @helpInterface.appendTo($("body"))
      @currentPage = 0
      @elementsChanged = false

      self = this

      unless @edit_mode
        @helpInterface.on 'click', =>
          @currentPage += 1

          if @currentPage >= @pageList.length
            @helpInterface.remove()
            @helpInterface = null
          else
            @showPage(@currentPage)
      else
        if @pageList.length is 0
          @createNewPage()

        @helpInterface.on 'click', -> HelpAnywhereEditor.focus(null)
        @helpInterface.find('.ha-page').on 'click', ->
          self.currentPage = $(this).attr('data-idx')
          self.showPage(self.currentPage)
        @helpInterface.find(".ha-new-page").on 'click', ->
          self.createNewPage()
        @helpInterface.find('.ha-add-component').on 'change', ->
          self.createNewComponent(self.currentPage, $(this).val())
          $(this).val('')
        @helpInterface.find('.ha-save-btn').on 'click', @saveHelp.bind(@)
        @helpInterface.find('.ha-exit-btn').on 'click', @closeHelpInterface.bind(@)

        @helpInterface.find('.ha-remove-page-btn').on 'click', @deletePage.bind(@)

      @showPage(@currentPage)

    saveHelp: ->
      $.post("#{HelpAnywhere.API_URL}/resources/save?name=#{@resource}", content: JSON.stringify(@pageList))
      .success =>
        @elementsChanged = false
      .error =>
        alert('Sorry, but something went wrong')

    retrieveResource: (resource) ->
      @resource = resource || @selectRoute window.location.pathname

      if @help?
        @help.css(display: 'none')


      if @resource
        $.get("#{HelpAnywhere.API_URL}/resources/?name=#{@resource}").success (data) =>
          if data.pages? and data.pages.length > 0
            @pageList = data.pages
            @buildInterface()
          else
            @pageList = []

  window.HelpAnywhere = HelpAnywhere
  window.HelpAnywhere.components = {}
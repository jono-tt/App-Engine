#<< AppEngine/Components/AppEngineComponent

class Page extends AppEngine.Components.AppEngineComponent
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['id', 'pageManager', 'transitionHandler'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['id', 'pageManager', 'transitionHandler', 'url', 'fetchStratergy'])

  @getShortNameIdentification: -> "app-engine-page"

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  constructor: (options = {})->
    super options
    @globalComponents = {}
    @_currentPageParams = new Backbone.Model()
    @logger.debug "'#{@id}': object has been created"

  initialise: (cb) ->
    pageInitialised = ->
      @logger.debug "'#{@id}': End initialise of page"
      cb()

    callback = ->
      if @childPageManager
        pageManagerInitialised = ->
          @logger.debug "'#{@id}': End initialise child page manager"
          pageInitialised.call(@)

        @logger.debug "'#{@id}': Start initialise child page manager"
        @childPageManager.initialise(pageManagerInitialised.createDelegate @)
      else 
        pageInitialised.call(@)

    @logger.debug "'#{@id}': Start initialise of page"
    super(callback.createDelegate @)

  reinitialise: (wrappedElement, cb) ->
    @wrappedElement = wrappedElement
    @dispose()

    @initialise(cb)

  ###
    ACCESSOR PROPERTIES
  ###

  # @property [String] The current parameters of this page
  getPageParams: () ->
    return @_currentPageParams

  ###

  ###
  setPageParams: (params) ->
    if _.isObject(params) or !params
      params = params or {}

      _.each(params, (value, name) ->
        @_currentPageParams.set(name, value)
      , @)
    else 
      throw new Error("Error: setPageParams expects params to be an object")

  ###
    END ACCESSOR PROPERTIES
  ###

  # applyConfigAttrib: (name, attribValue) ->
  #   if name is "transitionHandlerOptions"
  #     type = AppEngine.Helpers.getTypeFromConfig(attribValue, AppEngine.Transitions.ShowHideTransitionHandler)
  #     @logger.debug "'#{@id}': TransitionHandler: of type '#{type.getName()}' being used"
  #     @transitionHandler = AppEngine.Helpers.createObjectFromType(attribValue, type)
  #   else
  #     super name, attribValue

  addChild: (component, cb) ->
    #check if this is a page component
    if @pageManager.isPageComponent component
      @addChildPageComponents component
      cb()
    else
      #this is not a direct child page, check for nested pages and then add this as a component
      pageComponents = @pageManager.getPageElementsFromComponents component
      if pageComponents.length > 0
        @addChildPageComponents pageComponents

      componentCreated = (comp) ->
        if comp.scope
          @addGlobalComponent comp, comp.scope

        @children = @children or []
        @children.push comp
        cb(comp)

      #create this as a normal component (ie. not a page)
      @createChildComponent component, componentCreated.createDelegate(@)

  createChildComponent: (component, cb) ->
    try
      AppEngine.Helpers.createObjectByElementWrap component, { appConfig: @appConfig, page: @, wrappedElement: component }, cb
    catch e
      throw new AppEngine.Helpers.Error "Error occured creating component", e, component

  addChildPageComponents: (components) ->
    @childPageManager = @pageManager.getChildPageManager() if !@childPageManager

    components = [components] if !_.isArray(components)
    
    for comp in components
      @childPageManager.components.push(comp)

  ###
  @private
  ###
  addGlobalComponent: (component, scope = "page") ->
    switch scope
      when "page"
        if _.isUndefined @globalComponents[component.id]
          @logger.debug "'#{@id}': Global component '#{component.id}' is being registered to Page with scope of 'page'"
          @globalComponents[component.id] = component

          if component.on
            component.on "dispose", ((comp) ->
              @logger.debug "'#{@id}': Global component '#{component.id}' is being removed from the Page registry"
              delete @globalComponents[component.id]
            ).createDelegate(@)
        else
          @logger.error "'#{@id}': Global component '#{component.id}' has already been registered to this Page. Ignoring register request for component:", component.el
      else
        @pageManager.addGlobalComponent component, scope

  ###
  Dispose of this page cleanly
  ###
  dispose: () ->
    @logger.debug "'#{@id}': Dispose: Page Start"
    super()

    @childPageManager.dispose() if @childPageManager
    @childPageManager = null

    @logger.debug "'#{@id}': Dispose: Page Complete"

  ###
  @private
  ###
  loadPageContent: (url, cb) ->
    onReinitialised = ->
      @logger.debug "'#{@id}': Has been reinitialised"
      cb()

    callback = ->
      @logger.debug "'#{@id}': Reinitialising page"
      @isLoaded = true
      @wrappedElement.children = AppEngine.Helpers.ElementWrap.getTreeStructure(@el)
      @reinitialise(@wrappedElement, onReinitialised.createDelegate(@))

    @logger.debug "'#{@id}': Loading Page content from '#{url}'"
    @el.load(url, null, callback.createDelegate(@))


  #SECTION USED FOR SHOWING AND HIDING PAGES
  beforePageShow: (oldPage, pageParams, childPagesWithParams, success, cancelNavigation) ->

    doBeforePageShow = () ->
      _cancelNavigation = ((message)->
        @logger.debug "'#{@id}': beforePageShow: Navigation has been cancelled"
        @trigger("pageNavigationCancelled", @)
        cancelNavigation(message)
      ).createDelegate(@) if cancelNavigation

      if(oldPage == @)
        @logger.debug "'#{@id}': beforePageShow: The same page, different parameters"
        @beforeChildPageShow oldPage, childPagesWithParams, success, _cancelNavigation
      else
        @logger.debug "'#{@id}': beforePageShow: page has changed, check components are ok to continue"

        successCb = (() ->
          @beforeChildPageShow(oldPage, childPagesWithParams, success, _cancelNavigation)
        ).createDelegate(@)

        cancelCb = ((message) ->
          @logger.debug "'#{@id}': Components requested stopping of page show"
          _cancelNavigation(message)
        ).createDelegate(@) if _cancelNavigation

        @logger.debug "'#{@id}': beforePageShow is continuing to show "
        @triggerWithCallback("beforePageShown", successCb, cancelCb, oldPage, pageParams)

    # Check load stratergy to see if this must be loaded from a URL 
    if @url
      fetchStratergy = @fetchStratergy or "once"

      if ((fetchStratergy == 'once' and !@isLoaded) or (fetchStratergy == 'always'))
        return @loadPageContent(@url, doBeforePageShow.createDelegate(@))

    doBeforePageShow.call(@)


  ###
  @private
  ###
  beforeChildPageShow: (oldPage, childPagesWithParams, success, cancelNavigation) ->

    if @childPageManager
      continueCb = (->
        @logger.debug "'#{@id}': beforePageShow child page is continuing to show"
        success()
      ).createDelegate(@)

      cancelByChildPageCb = ((message) ->
        @logger.debug "'#{@id}': Child page requested stopping of page show"
        cancelNavigation(message)
      ).createDelegate(@) if cancelNavigation

      #slice the params to pass through to the child page manager to do the chaining correctly
      childPages = childPagesWithParams.slice(1)
      newpageWithParams = @childPageManager.getPageAndParamsFromList(childPagesWithParams)

      if newpageWithParams
        newpageWithParams.page.beforePageShow oldPage, newpageWithParams.params, childPages, continueCb, cancelByChildPageCb
      else
        continueCb()
    else
      @logger.debug "'#{@id}': beforePageShow no child pages, continuing to show"
      success()


  pageShow: (oldPage, pageParams, childPagesWithParams, cb) ->
    @setPageParams pageParams

    complete = ->
      oldPage.afterPageHide(@) if oldPage

      @logger.debug "'#{@id}': Triggering 'pageShown' event"
      @trigger "pageShown", oldPage, pageParams
      cb()

    if(oldPage != @)
      if oldPage
        @logger.debug "'#{@id}': pageShow: Transitioning from page '#{oldPage.id}'"
      else 
        @logger.debug "'#{@id}': pageShow: Transitioning to page. No old page present, perhaps first load.'"

      @transitionHandler.doTransition(oldPage, @, complete.createDelegate(@))
    else
      @logger.debug "pageShow: '#{@id}': This is the same page, dont transition"
      complete.call(@)

  afterPageShow: (oldPage, pageParams, childPagesWithParams, cb) ->
    @logger.debug("'#{@id}': afterPageShow")

    complete = ->
      @logger.debug "'#{@id}': Triggering 'afterPageShown' event"
      @trigger "afterPageShown", oldPage, pageParams
      cb()
    
    if @childPageManager
      @logger.debug "'#{@id}': afterPageShow: Calling child page manager navigateToPage"
      @childPageManager.navigateToPage(childPagesWithParams, complete.createDelegate(@))
    else
      @logger.debug "'#{@id}': afterPageShow: No Child Page Manager, continuing"
      complete.call(@)

  beforePageHide: (newPage, pageParams, childPagesWithParams, success, cancelNavigation) ->
    _cancelNavigation = ((message)->
      @logger.debug "'#{@id}': beforePageHide: Navigation has been cancelled"
      @trigger("pageNavigationCancelled", @)
      cancelNavigation(message)
    ).createDelegate(@)

    if(newPage == @)
      @logger.debug "#{@id}': beforePageHide: The same page, different parameters"
      @beforeChildPageHide childPagesWithParams, success, _cancelNavigation
    else
      @logger.debug "'#{@id}': beforePageHide: page has changed, check components are ok to continue"

      successCb = () ->
        @beforeChildPageHide(childPagesWithParams, success, _cancelNavigation)

      cancelCb = (message) ->
        @logger.debug "'#{@id}': Components requested stopping of page hide"
        _cancelNavigation(message)

      @logger.debug "'#{@id}': beforePageHide is continuing to hide "
      @triggerWithCallback("beforePageHide", successCb.createDelegate(@), cancelCb.createDelegate(@), newPage, pageParams)

  beforeChildPageHide: (childPagesWithParams, success, cancelNavigation) ->

    if @childPageManager
      continueCb = ->
        @logger.debug "'#{@id}': beforePageHide child page is continuing to hide"
        success()

      cancelByChildPageCb = (message) ->
        @logger.debug "'#{@id}': Child page requested stopping of page hide"
        cancelNavigation(message)

      #slice the params to pass through to the child page manager to do the chaining correctly
      childPages = childPagesWithParams.slice(1)
      newpageWithParams = @childPageManager.getPageAndParamsFromList(childPagesWithParams)

      if newpageWithParams
        @childPageManager.beforeCurrentPageHide newpageWithParams.page, newpageWithParams.params, childPages, continueCb.createDelegate(@), cancelByChildPageCb.createDelegate(@)
      else
        continueCb.call(@)
    else
      @logger.debug "'#{@id}': beforePageHide no child pages, continuing to hide"
      success()


  afterPageHide: (newPage) ->
    if newPage != @
      @logger.debug("'#{@id}': Triggering 'afterPageHidden' event")
      @trigger "afterPageHidden", newPage


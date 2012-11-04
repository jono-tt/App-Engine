#<< AppEngine/Components/AppEngineComponent

class Page extends AppEngine.Components.AppEngineComponent
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['id', 'pageManager', 'transitionHandler'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['id', 'pageManager', 'transitionHandler'])

  @getShortNameIdentification: -> "app-engine-page"

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  globalComponents: {}

  constructor: (options = {})->
    super options
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

  ###
    ACCESSOR PROPERTIES
  ###

  # @property [String] The current parameters of this page
  get currentPageParams: (@_currentPageParams) ->

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
        if(comp.scope)
          switch comp.scope
            when "page"
              if _.isUndefined @globalComponents[comp.id]
                @logger.debug "'#{@id}': Global component '#{comp.id}' is being registered to Page with scope of 'page'"
                @globalComponents[comp.id] = comp
              else
                @logger.error "'#{@id}': Global component '#{comp.id}' has already been registered to this Page. Ignoring register request for component:", comp.el
            else
              @pageManager.addGlobalComponent comp

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


  #SECTION USED FOR SHOWING AND HIDING PAGES
  beforePageShow: (oldPage, pageParams, childPagesWithParams, success, cancelNavigation) ->
    if(oldPage == @)
      @logger.debug "'#{@id}': beforePageShow: The same page, different parameters"
      @beforeChildPageShow oldPage, childPagesWithParams, success, cancelNavigation
    else
      @logger.debug "'#{@id}': beforePageShow: page has changed, check components are ok to continue"

      successCb = (() ->
        @beforeChildPageShow(oldPage, childPagesWithParams, success, cancelNavigation)
      ).createDelegate(@)

      cancelCb = ((message) ->
        @logger.debug "'#{@id}': Components requested stopping of page show"
        cancelNavigation()
      ).createDelegate(@) if cancelNavigation

      @logger.debug "'#{@id}': beforePageShow is continuing to show "
      @triggerWithCallback("beforePageShown", successCb, cancelCb, oldPage, pageParams)

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
        cancelNavigation()
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
    @_currentPageParams = pageParams

    complete = ->
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
    if(newPage == @)
      @logger.debug "#{@id}': beforePageHide: The same page, different parameters"
      @beforeChildPageHide childPagesWithParams, success, cancelNavigation
    else
      @logger.debug "'#{@id}': beforePageHide: page has changed, check components are ok to continue"

      successCb = () ->
        @beforeChildPageHide(childPagesWithParams, success, cancelNavigation)

      cancelCb = (message) ->
        @logger.debug "'#{@id}': Components requested stopping of page hide"
        cancelNavigation()

      @logger.debug "'#{@id}': beforePageHide is continuing to hide "
      @triggerWithCallback("beforePageHide", success.createDelegate(@), cancelCb.createDelegate(@), newPage, pageParams)

  beforeChildPageHide: (childPagesWithParams, success, cancelNavigation) ->

    if @childPageManager
      continueCb = ->
        @logger.debug "'#{@id}': beforePageHide child page is continuing to hide"
        success()

      cancelByChildPageCb = (message) ->
        @logger.debug "'#{@id}': Child page requested stopping of page hide"
        cancelNavigation()

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



  

  # pageHide: (newPage, pageParams, childPagesWithParams, cb) ->
  #   @logger.debug("'#{@id}': pageHide")
  #   cb()

  # afterPageHide: (newPage, pageParams, childPagesWithParams, cb) ->
  #   @logger.debug("'#{@id}': afterPageHide")
  #   cb()


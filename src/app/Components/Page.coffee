#<< AppEngine/Components/AppEngineComponent

class Page extends AppEngine.Components.AppEngineComponent
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['id', 'pageManager'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['id', 'pageManager'])

  @getShortNameIdentification: -> "app-engine-page"

  constructor: (config)->
    super config
    @logger.debug "'#{@id}': object has been created"

    @transition = new AppEngine.Transitions.ShowHideTransitionHandler({ duration: 500 })

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

      #create this as a normal component (ie. not a page)
      @createChildComponent component, cb

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
  beforePageShow: (oldPage, pageParams, childPagesWithParams, cb) ->
    if(oldPage == @)
      @logger.debug("'#{@id}': beforePageShow: The same page, different parameters")
    else 
      @logger.debug("'#{@id}': beforePageShow")

    cb()

  pageShow: (oldPage, pageParams, childPagesWithParams, cb) ->
    @currentPageParams = pageParams

    if(oldPage != @)
      if oldPage
        @logger.debug "pageShow: '#{@id}': Transitioning from page '#{oldPage.id}'"
      else 
        @logger.debug "pageShow: '#{@id}': Transitioning to page. No old page present, perhaps first load.'"

      @transition.doTransition(oldPage, @, cb)
    else
      @logger.debug "pageShow: '#{@id}': This is the same page, dont transition"
      cb()

  afterPageShow: (oldPage, pageParams, childPagesWithParams, cb) ->
    @logger.debug("'#{@id}': afterPageShow")
    
    if childPagesWithParams and childPagesWithParams.length > 0
      if @childPageManager
        @logger.debug "'#{@id}': Has child page params, calling child page manager"
        return @childPageManager.navigateToPage(childPagesWithParams, cb)
      else
        @logger.debug "'#{@id}': Has child page params, no Child Page Manager, continuing"
    else
      if @childPageManager
        @logger.debug "'#{@id}': Child Manager default page being called"
        #TODO: Should the default page be shown?
        return @childPageManager.navigateToDefaultPage(cb)
    
    cb()

  beforePageHide: (newPage, pageParams, childPagesWithParams, cb) ->
    if(newPage == @)
      @logger.debug "#{@id}': beforePageHide: The same page, different parameters"
    else
      @logger.debug "'#{@id}': beforePageHide: page has changed, check components are ok to continue"

      if @triggerEventWithCancelOption("beforePageHide", [newPage, pageParams])
        @logger.debug "'#{@id}': Components requested stopping of page hide"
        return false

    if @childPageManager
      childPage = @childPageManager.getCurrentPage()
      if childPage
        @logger.debug "'#{@id}': Calling beforePageHide for child page '#{childPage.id}"
        return childPage.beforePageHide newPage, pageParams, childPagesWithParams, cb


    @logger.debug "'#{@id}': beforePageHide is continuing to hide "        
    cb()
    return true

  triggerEventWithCancelOption: (eventName, args) ->
    doCancel = false

    cancel = (mustCancel) ->
      doCancel = doCancel || mustCancel

    newArgs = _.union([cancel], args)

    this.trigger(eventName, newArgs)
    return doCancel

  # pageHide: (newPage, pageParams, childPagesWithParams, cb) ->
  #   @logger.debug("'#{@id}': pageHide")
  #   cb()

  # afterPageHide: (newPage, pageParams, childPagesWithParams, cb) ->
  #   @logger.debug("'#{@id}': afterPageHide")
  #   cb()


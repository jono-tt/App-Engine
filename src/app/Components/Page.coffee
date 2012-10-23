#<< AppEngine/Components/AppEngineComponent

class Page extends AppEngine.Components.AppEngineComponent
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['id', 'pageManager'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['id', 'pageManager'])

  @getShortNameIdentification: -> "app-engine-page"

  constructor: (config)->
    super config
    @logger.debug "Page: '#{@id}': object has been created"

  initialise: (cb) ->
    pageInitialised = ->
      @logger.debug "Page: '#{@id}': End initialise of page"
      cb()

    callback = ->
      if @childPageManager
        pageManagerInitialised = ->
          @logger.debug "Page: '#{@id}': End initialise child page manager"
          pageInitialised.call(@)

        @logger.debug "Page: '#{@id}': Start initialise child page manager"
        @childPageManager.initialise(pageManagerInitialised.createDelegate @)
      else 
        pageInitialised.call(@)

    @logger.debug "Page: '#{@id}': Start initialise of page"
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

      #create this as a normal component
      @createChildComponent component, cb

  createChildComponent: (component, cb) ->
    try
      AppEngine.Helpers.createObjectByElementWrap component, { appConfig: @appConfig, page: @, wrappedElement: component }, cb
    catch e
      throw new AppEngine.Helpers.Error "Page: Error occured creating component", e, component

  addChildPageComponents: (components) ->
    @childPageManager = @pageManager.getChildPageManager() if !@childPageManager

    components = [components] if !_.isArray(components)
    
    for comp in components
      @childPageManager.components.push(comp)


  #SECTION USED FOR SHOWING AND HIDING PAGES
  beforePageShow: (oldPage, pageParams, childPagesWithParams, cb) ->
    if(oldPage == @)
      @logger.debug("Page: '#{@id}': beforePageShow: The same page, different parameters")
    else 
      @logger.debug("Page: '#{@id}': beforePageShow")

    cb()

  pageShow: (oldPage, pageParams, childPagesWithParams, cb) ->
    @currentPageParams = pageParams

    if(oldPage != @)
      if oldPage
        @logger.debug "Page: pageShow: '#{@id}': Transitioning from page '#{oldPage.id}'"
      else 
        @logger.debug "Page: pageShow: '#{@id}': Transitioning to page. No old page present, perhaps first load.'"

    else
      @logger.debug "Page: pageShow: '#{@id}': This is the same page, dont transition"
      cb()

  afterPageShow: (oldPage, pageParams, childPagesWithParams, cb) ->
    @logger.debug("Page: '#{@id}': afterPageShow")
    
    if childPagesWithParams and childPagesWithParams.length > 0
      if @childPageManager
        @logger.debug "Page: '#{@id}': Has child page params, calling child page manager"
        return @childPageManager.navigateToPage(childPagesWithParams, cb)
      else
        @logger.debug "Page: '#{@id}': Has child page params, no Child Page Manager, continuing"
    else
      if @childPageManager
        @logger.debug "Page: '#{@id}': Child Manager default page being called"
        #TODO: Should the default page be shown?
        return @childPageManager.navigateToDefaultPage(cb)
    
    cb()

  beforePageHide: (newPage, pageParams, childPagesWithParams, cb) ->
    if(newPage == @)
      @logger.debug("Page: '#{@id}': beforePageHide: The same page, different parameters")
    else 
      @logger.debug("Page: '#{@id}': beforePageHide")

    cb()
    return true

  # pageHide: (newPage, pageParams, childPagesWithParams, cb) ->
  #   @logger.debug("Page: '#{@id}': pageHide")
  #   cb()

  # afterPageHide: (newPage, pageParams, childPagesWithParams, cb) ->
  #   @logger.debug("Page: '#{@id}': afterPageHide")
  #   cb()

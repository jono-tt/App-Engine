#<< AppEngine/Components/AppEngineComponent

class Page extends AppEngine.Components.AppEngineComponent
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['id', 'pageManager'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['id', 'pageManager'])

  @getShortNameIdentification: -> "app-engine-page"

  constructor: (config)->
    super config
    console.debug "Page: '#{@id}': object has been created"

  initialise: (cb) ->
    pageInitialised = ->
      console.debug "Page: '#{@id}': End initialise of page"
      cb()

    callback = ->
      if @childPageManager
        pageManagerInitialised = ->
          console.debug "Page: '#{@id}': End initialise child page manager"
          pageInitialised.call(@)

        console.debug "Page: '#{@id}': Start initialise child page manager"
        @childPageManager.initialise(pageManagerInitialised.createDelegate @)
      else 
        pageInitialised.call(@)

    console.debug "Page: '#{@id}': Start initialise of page"
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
    console.debug("Page: '#{@id}': beforePageShow")
    cb()

  pageShow: (oldPage, pageParams, childPagesWithParams, cb) ->
    console.debug("Page: '#{@id}': pageShow")
    cb()

  afterPageShow: (oldPage, pageParams, childPagesWithParams, cb) ->
    console.debug("Page: '#{@id}': afterPageShow")
    if @childPageManager
      #this has child pages that need to be called
      if childPagesWithParams.length > 0
        #there are parameters for the child page manager
        return @childPageManager.navigateToPage(childPagesWithParams, cb)
      else
        #navigate to the default page o the child page manager
        return @childPageManager.navigateToDefaultPage(cb)
    
    cb()

  beforePageHide: (newPage, pageParams, childPagesWithParams, cb) ->
    console.debug("Page: '#{@id}': beforePageHide")
    if(!pageParams or !pageParams.dont)
      cb()
    else
      return false

  # pageHide: (newPage, pageParams, childPagesWithParams, cb) ->
  #   console.debug("Page: '#{@id}': pageHide")
  #   cb()

  # afterPageHide: (newPage, pageParams, childPagesWithParams, cb) ->
  #   console.debug("Page: '#{@id}': afterPageHide")
  #   cb()

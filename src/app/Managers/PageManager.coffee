#<< AppEngine/Objects/StrictObject

class PageManager extends AppEngine.Objects.StrictObject
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['appConfig'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['appConfig', 'components', 'pageDefaultConfig', 'pageClassIdentifier', 'parentManager'])

  constructor: (config) ->
    try
      #set the default properies
      _.defaults(config, { 
        pageClassIdentifier: 'pseudo-page',
        pageDefaultConfig: {},
        components: []
      })

      super config
    catch e
      throw new AppEngine.Helpers.Error "PageManager: Creating new instance", e

    #set the default Page type
    @pageDefaultConfig.type = AppEngine.Components.Page.getShortNameIdentification() if !@pageDefaultConfig.type

  initialise: (cb)->
    try 
      pagesInitialiseComplete = (pages)->
        @pages = {}
        for page in pages
          @pages[page.id] = page

        cb()

      pageDefConfig = { pageManager: @ }
      _.defaults pageDefConfig, @pageDefaultConfig

      addPage = (item, callback) ->
        AppEngine.Helpers.createObjectByElementWrap item, pageDefConfig, callback

      #go through each component on the page and make sure it has an appropriate
      pageWrappers = []
      for comp in @components
        if @isPageComponent comp
          pageWrappers.push comp
        else
          console.log "PageManager: Component is outside of a page so cannot be created: "
          console.log comp.el

      if pageWrappers.length > 0
        #go through each page wrapper and create a page
        AppEngine.Helpers.asyncCallEach pageWrappers, addPage.createDelegate(@), pagesInitialiseComplete.createDelegate(@)
      else
        console.warn "PageManager: Unable to find any Pages in the web component root"
        cb()
    catch e
      throw new AppEngine.Helpers.Error "PageManager: initialising", e

  #This will return the first level pages from the list of components
  getPageElementsFromComponents: (components, pages) ->
    components = [components] if !_.isArray(components)
    pages = pages or []
    for comp in components
      if @isPageComponent comp
        pages.push comp
      else
        @getPageElementsFromComponents(comp.children, pages)

    return pages

  isPageComponent: (component) ->
    return component.el.hasClass(@pageClassIdentifier)

  getChildPageManager: () ->
    return new PageManager({
      appConfig: @appConfig,
      pageDefaultConfig: @pageDefaultConfig,
      pageClassIdentifier: @pageClassIdentifier,
      parentManager: @
    })

  #Page Navigation
  navigateToPage: (pagenamesWithParams, navigationComplete) ->
    if pagenamesWithParams.length > 0
      page = @pages[pagenamesWithParams[0].pageName]

      if page
        #take the first page off the stack and retrieve the parameters
        pageParams = pagenamesWithParams.shift().params

        #navigate to the page
        _navigateToPage page, pageParams, pagenamesWithParams, navigationComplete
      else
        #cannot find page, navigate to default
        @navigateToDefaultPage(navigationComplete)
    else
      console.debug "PageManager: There are 0 pages to try display"

  navigateToDefaultPage: (navigationComplete) ->
    console.log "navigate to default page"
    navigationComplete()
    return true

  _navigateToPage = (newpage, pageParams, childPagesAndParams, navigationComplete) ->
    afterPageShownComplete = ->
      console.debug "PageManager: Transition to page #{newpage.id} complete"
      navigationComplete()

    pageShown = ->
      console.debug "PageManager: page #{newpage.id} shown, firing afterPageShow"
      @currentPage = newpage
      newpage.afterPageShow @currentPage, pageParams, childPagesAndParams, afterPageShownComplete.createDelegate(@)
    
    pageShow = ->
      newpage.pageShow @currentPage, pageParams, childPagesAndParams, pageShown.createDelegate(@)

    beforePageShown = ->
      newpage.beforePageShow @currentPage, pageParams, childPagesAndParams, pageShow.createDelegate(@)


    #if there is an old page, let the old page decide if it wants to opt out before navigaigation
    if @currentPage
      #if this returns immediately with false the navigation will be stopped
      return @currentPage.beforePageHide newpage, pageParams, childPagesAndParams, beforePageShown.createDelegate(@)
    else
      beforePageShown()

    return true




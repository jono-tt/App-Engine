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

      @specialPages = {
        defaultPage: null,
        notFoundPage: null,
        errorPage: null
      }

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

          @setSpecialPages(page)

        #check if a default page was not set
        if !@specialPages.defaultPage
          if pages.length > 0
            @specialPages.defaultPage = pages[0]
            console.debug "PageManager: Default page was not found so reverting to using '#{@specialPages.defaultPage.id}' as default"
          else
            console.warn "PageManager: Default page not set as there are no pages"

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


  setSpecialPages: (page) ->
    if page.isDefaultPage
      if !@specialPages.defaultPage
        @specialPages.defaultPage = page
        console.debug "PageManager: Default page has been set to '#{@specialPages.defaultPage.id}'"
      else
        console.warn "PageManager: Page '#{@specialPages.defaultPage.id} is already set as default. Ignoring change to '#{page.id}'"

    if page.isNotFoundPage
      if !@specialPages.notFoundPage
        @specialPages.notFoundPage = page
        console.debug "PageManager: Not Found page has been set to '#{@specialPages.notFoundPage.id}'"
      else
        console.warn "PageManager: Page '#{@specialPages.notFoundPage.id} is already set as Not Found page. Ignoring change to '#{page.id}'"

    if page.isErrorPage
      if !@specialPages.errorPage
        @specialPages.errorPage = page
        console.debug "PageManager: Error page has been set to '#{@specialPages.errorPage.id}'"
      else
        console.warn "PageManager: Page '#{@specialPages.errorPage.id} is already set as Error page. Ignoring change to '#{page.id}'"

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
        return @_navigateToPage page, pageParams, pagenamesWithParams, navigationComplete
      else
        console.debug "PageManager: Unable to find page '#{pagenamesWithParams[0].pageName}', routing to page not found"  
        return @navigateToPageNotFound(pagenamesWithParams, navigationComplete)

    #cannot find page, navigate to default
    console.debug "PageManager: Pagenames with params is empty, routing to default"
    return @navigateToDefaultPage(navigationComplete)   

  navigateToPageNotFound: (pagenamesWithParams, navigationComplete) ->
    if @specialPages.notFoundPage
      console.debug "PageManager: Navigating to Not Found page '#{@specialPages.notFoundPage.id}'"
      return @_navigateToPage(@specialPages.notFoundPage, null, [], navigationComplete)
    else
      console.debug "PageManager: Not Found page has not been set, route to default page"
      return @navigateToDefaultPage(navigationComplete)

  navigateToErrorPage: (pagenamesWithParams, navigationComplete) ->
    if @specialPages.errorPage
      console.debug "PageManager: Navigating to Error page '#{@specialPages.errorPage.id}'"
      return @_navigateToPage(@specialPages.errorPage, null, [], navigationComplete)
    else
      console.debug "PageManager: Error page has not been set, route to default page"
      return @navigateToDefaultPage(navigationComplete)

  navigateToDefaultPage: (navigationComplete) ->
    if @specialPages.defaultPage
      console.debug "PageManager: Navigating to default page '#{@specialPages.defaultPage.id}'"
      return @_navigateToPage(@specialPages.defaultPage, null, [], navigationComplete)
    else
      console.error "PageManager: No default page so just exiting with return of false"
      return false

  _navigateToPage: (newpage, pageParams, childPagesAndParams, navigationComplete) ->
    afterPageShownComplete = ->
      console.debug "PageManager: Transition to page #{newpage.id} complete"
      navigationComplete()

    pageShown = ->
      console.debug "PageManager: Page #{newpage.id} shown, firing afterPageShow"
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
      beforePageShown.createDelegate(@)()

    return true




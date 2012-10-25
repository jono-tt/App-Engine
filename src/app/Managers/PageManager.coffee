#<< AppEngine/Objects/StrictObject

class PageManager extends AppEngine.Objects.StrictObject
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['appConfig'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['appConfig', 'components', 'pageDefaultConfig', 'pageClassIdentifier', 'parentManager'])

  constructor: (options = {}) ->
    try
      #set the default properies
      _.defaults(options, { 
        pageClassIdentifier: 'pseudo-page',
        pageDefaultConfig: {},
        components: []
      })

      @specialPages = {
        defaultPage: null,
        notFoundPage: null,
        errorPage: null
      }

      super options
    catch e
      throw new AppEngine.Helpers.Error "Creating new instance", e

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
            @logger.debug "Default page was not found so reverting to using '#{@specialPages.defaultPage.id}' as default"
          else
            @logger.warn "Default page not set as there are no pages"

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
          @logger.log "Component is outside of a page so cannot be created: "
          @logger.log comp.el

      if pageWrappers.length > 0
        #go through each page wrapper and create a page
        AppEngine.Helpers.asyncCallEach pageWrappers, addPage.createDelegate(@), pagesInitialiseComplete.createDelegate(@)
      else
        @logger.warn "Unable to find any Pages in the web component root"
        cb()
    catch e
      throw new AppEngine.Helpers.Error "initialising", e


  setSpecialPages: (page) ->
    if page.isDefaultPage
      if !@specialPages.defaultPage
        @specialPages.defaultPage = page
        @logger.debug "Default page has been set to '#{@specialPages.defaultPage.id}'"
      else
        @logger.warn "Page '#{@specialPages.defaultPage.id} is already set as default. Ignoring change to '#{page.id}'"

    if page.isNotFoundPage
      if !@specialPages.notFoundPage
        @specialPages.notFoundPage = page
        @logger.debug "Not Found page has been set to '#{@specialPages.notFoundPage.id}'"
      else
        @logger.warn "Page '#{@specialPages.notFoundPage.id} is already set as Not Found page. Ignoring change to '#{page.id}'"

    if page.isErrorPage
      if !@specialPages.errorPage
        @specialPages.errorPage = page
        @logger.debug "Error page has been set to '#{@specialPages.errorPage.id}'"
      else
        @logger.warn "Page '#{@specialPages.errorPage.id} is already set as Error page. Ignoring change to '#{page.id}'"

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

  getCurrentPage: () ->
    return @currentPage

  getPageAndParamsFromList: (pagenamesWithParams) ->
    if pagenamesWithParams.length > 0
      page = @pages[pagenamesWithParams[0].pageName]

      if page
        @logger.debug "Page '#{page.id}' found from pagenamesWithParams"
        return page: page, params: pagenamesWithParams[0].params
      else
        @logger.debug "Unable to find page '#{pagenamesWithParams[0].pageName}' in page manager", @
    else if @specialPages.defaultPage
      @logger.debug "No page names, Use Default Page '#{ @specialPages.defaultPage.id}'"
      return page: @specialPages.defaultPage, params: {}

    if @specialPages.notFoundPage
      @logger.debug "Page Not Found '#{ @specialPages.notFoundPage.id}' is being used"
      return page: @specialPages.notFoundPage, params: {}
    else
      @logger.debug "Unable to find a valid page to return. This should not occur, configure a Not Found Page"

    return null

  #Page Navigation
  navigateToPage: (pagenamesWithParams, navigationComplete, cancelNavigation) ->
    pageAndParams = @getPageAndParamsFromList(pagenamesWithParams)

    if pageAndParams
      #take the first page off the stack and retrieve the parameters
      pagenamesWithParams.shift()

      #navigate to the page
      return @_navigateToPage pageAndParams.page, pageAndParams.params, pagenamesWithParams, navigationComplete, cancelNavigation
    else if cancelNavigation
      cancelNavigation()


  _navigateToPage: (newpage, pageParams, childPagesAndParams, navigationComplete, cancelNavigation) ->
    afterPageShownComplete = ->
      @logger.debug "Transition to page #{newpage.id} complete"
      navigationComplete()

    pageShown = ->
      @logger.debug "Page #{newpage.id} shown, firing afterPageShow"
      @currentPage = newpage
      newpage.afterPageShow @currentPage, pageParams, childPagesAndParams, afterPageShownComplete.createDelegate(@)
    
    pageShow = ->
      newpage.pageShow @currentPage, pageParams, childPagesAndParams, pageShown.createDelegate(@)

    beforePageShown = ->
      newpage.beforePageShow @currentPage, pageParams, childPagesAndParams, pageShow.createDelegate(@), cancelNavigation

    #if there is an old page, let the old page decide if it wants to opt out before navigaigation
    if @currentPage and cancelNavigation
      #if this returns immediately with false the navigation will be stopped
      @beforeCurrentPageHide newpage, pageParams, childPagesAndParams, beforePageShown.createDelegate(@), cancelNavigation
    else
      beforePageShown.call(this)

    return true

  beforeCurrentPageHide: (newpage, pageParams, childPagesAndParams, navigationComplete, cancelNavigation) ->
    #if there is an old page, let the old page decide if it wants to opt out before navigaigation
    if @currentPage
      @logger.debug "Page #{@currentPage.id} beforePageHide firing"
      #if this returns immediately with false the navigation will be stopped
      @currentPage.beforePageHide newpage, pageParams, childPagesAndParams, navigationComplete, cancelNavigation
    else
      navigationComplete(this)





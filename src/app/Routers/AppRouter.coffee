
class AppRouter extends Backbone.Router
  constructor: (config) ->
    config = config or {}
    if !config.pageManager
      throw new Error "Unable to start Router without an PageManager being passed into the Constructor"
    
    @pageManager = config.pageManager
    
    if config.parameterParser
      @parameterParser = config.parameterParser
    else
      @parameterParser = new AppEngine.Routers.JsonParameterParser

    super(config)

  initialize: (options) ->
    #http://backbonejs.org/#Router-route

    for page in @pageManager.pages
      #create the page route
      @route "#{page.id}/*splat", page.id + "_withparams"
      @route "#{page.id}", page.id + "_noparams"

      #create the mapper to the pageManager

      @on "route:" + page.id + "_withparams", @routeChangeToPageWithParams.createDelegate(@, [page], true)
      @on "route:" + page.id + "_noparams", @routeChangeToPageNoParams.createDelegate(@, [page], true)

  routeChangeToPageWithParams: (params, page) ->
    fixedParameters = @parameterParser.parseParameters(params)
    @pageManager.navigateToPage(page, fixedParameters)

  routeChangeToPageNoParams: (page) ->
    @pageManager.navigateToPage(page, null)
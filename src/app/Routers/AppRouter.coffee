
class AppRouter extends Backbone.Router
  routes: {
    "*splat": "routeChange"
  }
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


  routeChange: (params) ->
    if params
      pageParams = @parameterParser.parseParameters(params)

      if pageParams
        @pageManager.navigateToPage(pageParams)
        return

    #no params, route to default page
    @pageManager.navigateToDefaultPage()

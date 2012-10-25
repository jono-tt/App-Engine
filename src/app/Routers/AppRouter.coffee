#<< AppEngine/Helpers/Logger

class AppRouter extends Backbone.Router
  logger = new AppEngine.Helpers.Logger(@)
  
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
    navigationComplete = ->
      @previousParams = params
      logger.debug "AppRouter: All page transitions complete", params

    cancelNavigation = ->
      logger.debug "Navigation has cancelled the request"
      if @previousParams
        @navigate(@previousParams, {trigger: false, replace: true});

    if params
      pageParams = @parameterParser.parseParameters(params)

      if pageParams.length > 0
        @pageManager.navigateToPage(pageParams, navigationComplete.createDelegate(@), cancelNavigation.createDelegate(@))
        return
    
    #no params, route to default page
    @pageManager.navigateToDefaultPage(navigationComplete.createDelegate(@), cancelNavigation.createDelegate(@))


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
    navigationComplete = ->
      @previousParams = params
      console.debug "AppRouter: All page transitions complete", params

    if params
      pageParams = @parameterParser.parseParameters(params)

      if pageParams.length > 0
        if !@pageManager.navigateToPage(pageParams, navigationComplete.createDelegate(@))
          @revertNavigationChange()

        return
    
    #no params, route to default page
    if ! @pageManager.navigateToDefaultPage(navigationComplete)
      #Revert navigation if the page has
      @revertNavigationChange()

  
  revertNavigationChange: ->
    if @previousParams
      @navigate(@previousParams, {trigger: false, replace: true});

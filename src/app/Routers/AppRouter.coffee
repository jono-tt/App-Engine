#<< AppEngine/Helpers/Logger

###
AppRouter is the default application routing Class used to make the routing of Pages through the pageManager

@example How to generate an custom error
  var router = new AppRouter({
    pageManager: PageManager,
    parameterParser: ParameterParser
  });
###

class AppRouter extends Backbone.Router
  logger = new AppEngine.Helpers.Logger(@)
  
  routes: {
    "*splat": "routeChange"
  }

  ###
  @param [Object] options app router properties
  @option pageManager [PageManager] the page manager to use
  @option parameterParser [ParameterParser] the object that will parse out the page and parameters
  ###
  constructor: (options = {}) ->
    AppEngine.Helpers.assertParametersExist ["pageManager", "parameterParser"], options
    @pageManager = options.pageManager
    @parameterParser = options.parameterParser
    
    super(options)

  ###
  @private
  ###
  initialize: (options) ->
    #http://backbonejs.org/#Router-route

  ###
  @private
  ###
  routeChange: (params) ->
    navigationComplete = ->
      @previousParams = params
      logger.debug "AppRouter: All page transitions complete", params

    cancelNavigation = ->
      logger.debug "Navigation has cancelled the request"
      if @previousParams
        @navigate(@previousParams, {trigger: false, replace: true});

    if params
      pagesAndParams = @parameterParser.parseParameters(params)

      if pagesAndParams.length > 0
        @pageManager.navigateToPage(pagesAndParams, navigationComplete.createDelegate(@), cancelNavigation.createDelegate(@))
        return
    
    #no params, route to default page
    @pageManager.navigateToDefaultPage(navigationComplete.createDelegate(@), cancelNavigation.createDelegate(@))

class EngineController
  constructor: (appConfig = {}) ->
    @appConfig = appConfig

  initialise: (cb) ->
    try

      initRouterComplete = (router) ->
        @appRouter = router
        cb()

      initRouter = ->
        AppEngine.Helpers.getObjectByConfig {appConfig: @appConfig, pageManager: @pageManager, parameterParser: @parameterParser}, @appConfig.router, AppEngine.Routers.AppRouter, initRouterComplete.createDelegate(@)

      initParameterParserComplete = (parser) ->
        @parameterParser = parser
        initRouter.call(@)

      initParameterParser = ->
        AppEngine.Helpers.getObjectByConfig {appConfig: @appConfig}, @appConfig.parameterParser, AppEngine.Routers.JsonParameterParser, initParameterParserComplete.createDelegate(@)


      @initPageManager initParameterParser.createDelegate(@)
    catch e
      throw new AppEngine.Helpers.Error "EngineController: initialising PageManager", e

  initPageManager: (cb) ->
    #get all the 'components' on the page that can be compontentised
    components = AppEngine.Helpers.ElementWrap.getTreeStructure()

    pageManagerInitialised = (manager) ->
      @pageManager = manager
      cb()

    pageManagerConfig = @appConfig.pageManager or {}
    AppEngine.Helpers.getObjectByConfig {appConfig: @appConfig, components: components}, pageManagerConfig, AppEngine.Managers.PageManager, pageManagerInitialised.createDelegate(@)


  start: ->
    # TODO: engine startup

  


class EngineController
  constructor: (appConfig = {}) ->
    @appConfig = appConfig
    @rootElement = appConfig.rootElement or $j("body")

  initialise: (cb) ->
    try
      @logger = new AppEngine.Helpers.Logger(EngineController)

      initComplete = () ->
        @logger.log "Initialisation of EngineController complete"
        cb()

      initRouter = ->
        @initRouter(initComplete.createDelegate(@))

      initPM = ->
        @initPageManager(initRouter.createDelegate(@))

      @initParameterParser(initPM.createDelegate(@))
    catch e
      throw new AppEngine.Helpers.Error "EngineController: initialising PageManager", e

  initRouter: (cb) ->
    initComplete = (router) ->
      @appRouter = router
      cb()

    AppEngine.Helpers.getObjectByConfig {appConfig: @appConfig, pageManager: @pageManager, parameterParser: @parameterParser}, @appConfig.router, AppEngine.Routers.AppRouter, initComplete.createDelegate(@)


  initParameterParser: (cb) ->
    initParameterParserComplete = (parser) ->
        @parameterParser = parser
        cb()

    AppEngine.Helpers.getObjectByConfig {appConfig: @appConfig}, @appConfig.parameterParser, AppEngine.Routers.JsonParameterParser, initParameterParserComplete.createDelegate(@)

  initPageManager: (cb) ->
    #get all the 'components' on the page that can be compontentised
    components = AppEngine.Helpers.ElementWrap.getTreeStructure(@rootElement)

    pageManagerInitialised = (manager) ->
      @pageManager = manager
      cb()

    pageManagerConfig = @appConfig.pageManager or {}
    AppEngine.Helpers.getObjectByConfig {appConfig: @appConfig, components: components, parameterParser: @parameterParser}, pageManagerConfig, AppEngine.Managers.PageManager, pageManagerInitialised.createDelegate(@)


  start: ->
    # TODO: engine startup

  


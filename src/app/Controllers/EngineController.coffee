class EngineController
  constructor: (appConfig) ->
    @appConfig = appConfig or {}

  initialise: (cb) ->
    try
      initRouter = ->
        @appRouter = new AppEngine.Routers.AppRouter({ pageManager: @pageManager })
        cb()

      @initPageManager initRouter.createDelegate(@)
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

  


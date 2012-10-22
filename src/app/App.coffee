@$j = jQuery.noConflict()
@$OuterScope = @;

class App
  constructor: (cb) ->
    try 
      @appConfig = AppEngine.Helpers.getApplicationConfig() || {}
    catch e
      console.error "Error: Loading application config"
      e.log() if _.isFunction(e.log)
      return

    #setup logger
    AppEngine.Helpers.Logger.setupLogger(@appConfig.logger)

    #configure the application
    console.debug "AppConfig loaded: #{JSON.stringify @appConfig}";

    @setupComponentRegistry()

    #setup the engine controller
    engine = new AppEngine.Controllers.EngineController @appConfig;

    logError = (message, e) ->
      if(console.isError)
        console.error message
        if _.isFunction(e.log)
          e.log() 
        else
          console.error e

    try
      console.log 'Engine initialise start'
      engine.initialise ->
        console.log 'Engine initialise complete'

        try
          console.log 'Engine starting';
          engine.start
          console.log 'Engine starting complete';
          cb()
        catch e
          logError "Error: Engine start failure", e
    catch e
      logError "Error: Engine initialise failure", e

  setupComponentRegistry: ->
    scopes = []

    if @appConfig.componentRegistryNamespaces && @appConfig.componentRegistryNamespaces.length > 0
      for ns in @appConfig.componentRegistryNamespaces
        obj = AppEngine.Helpers.getObjectByPath ns, $OuterScope
        scopes.push obj if obj

    scopes = [window] if scopes.length == 0
  
    #initialise component registry
    AppEngine.initialiseComponentRegistry(scopes)
    




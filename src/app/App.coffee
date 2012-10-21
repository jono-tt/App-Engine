@$j = jQuery.noConflict()
@$OuterScope = @;

class App
  constructor: (cb) ->
    try 
      @appConfig = AppEngine.Helpers.getApplicationConfig()
    catch e
      console.error "Error: Loading application config"
      e.log() if _.isFunction(e.log)
      return

    #configure the application
    @setupLogger()
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
    

  setupLogger: ->
    console.isDebug = @appConfig.logger and @appConfig.logger.debug == "true"
    dontWarn = @appConfig.logger and @appConfig.logger.warn == "false"
    dontLog = @appConfig.logger and @appConfig.logger.log == "false"
    dontError = @appConfig.logger and @appConfig.logger.error == "false"

    if !console.isDebug
      console.debug = ->

    if dontWarn
      console.warn = -> 
      console.isWarn = false
    else
      console.isWarn = true

    if dontLog
      console.isLog = false
      console.log "Disabling console 'log'"
      console.log = -> 
    else
      console.isLog = true

    if dontError
      console.isError = false
      console.log "Disabling console 'error'"
      console.error = -> 
    else
      console.isError = true





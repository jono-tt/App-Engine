class Logger
  constructor: (klass) ->
    klassName = klass.constructor.getName()

    #set logger
    if Logger.isLog or Logger.logClasses[klassName]
      @log = ->
        args = getLogMessage klassName, _.toArray(arguments)
        console.log.apply(klass, args)
    else
      @log = -> false

    #set debug logger
    if Logger.isDebug or Logger.debugClasses[klassName]
      @debug = ->
        args = getLogMessage klassName, _.toArray(arguments)
        console.debug.apply(klass, args)
    else
      @debug = -> false

    #set warn logger
    if Logger.isWarn or Logger.warnClasses[klassName]
      @warn = ->
        args = getLogMessage klassName, _.toArray(arguments)
        console.warn.apply(klass, args)
    else
      @warn = -> false

    #set error logger
    if Logger.isError or Logger.errorClasses[klassName]
      @error = ->
        args = getLogMessage klassName, _.toArray(arguments)
        console.error.apply(klass, args)
    else
      @error = -> false


  getLogMessage = (klassName, args) ->
    if args and args.length > 0
      args[0] = "#{klassName}: " + args[0]
      return args
    else
      return [ "#{klassName}: " ]


  @debugClasses = {}
  @warnClasses = {}
  @logClasses = {}
  @errorClasses = {}

  @resetLogger: () ->
    Logger.debugClasses = {}
    Logger.warnClasses = {}
    Logger.logClasses = {}
    Logger.errorClasses = {}

  @setupLogger: (loggerConfig) ->
    loggerConfig = loggerConfig or {}

    Logger.isDebug = loggerConfig.debug == "true"
    Logger.isWarn = !loggerConfig.warn or loggerConfig.warn == "true"
    Logger.isLog = !loggerConfig.log or loggerConfig.log == "true"
    Logger.isError = !loggerConfig.error or loggerConfig.error == "true"

    #check if these are class specific logging rules
    if(!Logger.isDebug)
      if(Logger.addLoggerClasses(loggerConfig.debug, Logger.debugClasses))
        console.debug "Logger: Enabled debugging logs by classes:- "
        _.each Logger.debugClasses, (value, name) ->
          console.debug "class: '#{name}'"
      else
         console.debug "Logger: Disabling debugging logs"
    else
      console.debug "Logger: Enabled all debugging logs"


    if(!Logger.isWarn)
      if Logger.addLoggerClasses(loggerConfig.warn, Logger.warnClasses)
        console.log "Logger: Enabled warn logs by classes:- "
        _.each Logger.warnClasses, (value, name) ->
          console.log "class: '#{name}'"
      else
         console.log "Logger: Disabling warn logs"
    else
      console.log "Logger: Enabled all warn logs"


    if(!Logger.isLog)
      if Logger.addLoggerClasses(loggerConfig.log, Logger.logClasses)
        console.log "Logger: Enabled console logs by classes:- "
        _.each Logger.logClasses, (value, name) ->
          console.log "class: '#{name}'"
      else
         console.log "Logger: Disabling console logs"
    else
      console.log "Logger: Enabled all console logs"

    if(!Logger.isError)
      if Logger.addLoggerClasses(loggerConfig.error, Logger.errorClasses)
        console.log "Logger: Enabled error logs by classes:- "
        _.each Logger.errorClasses, (value, name) ->
          console.log "class: '#{name}'"
      else
         console.log "Logger: Disabling error logs"
    else
      console.log "Logger: Enabled all error logs"



  @addLoggerClasses: (classNameList, registry) ->
    isClassEnabled = false

    if _.isArray(classNameList)
      for klassName in classNameList
        type = AppEngine.Helpers.getTypeFromTypeName(klassName)
        if(type)
          registry[type.getName()] = type
          isClassEnabled = true

    return isClassEnabled

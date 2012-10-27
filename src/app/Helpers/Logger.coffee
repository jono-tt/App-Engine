class Logger
  constructor: (klass) ->
    klassName = null
    logStartValue = ""

    if klass.constructor && klass.constructor.getName
      klassName = klass.constructor.getName() 
      logStartValue = klassName + ": "
    else if typeof klass == "String"
      logStartValue = klass

    console.log klass

    #set logger
    if Logger.isLog or Logger.logClasses[klassName]
      @log = ->
        args = getLogMessage logStartValue, _.toArray(arguments)
        for a in args
          console.log a

        return true
    else
      @log = -> false

    #set debug logger
    if Logger.isDebug or Logger.debugClasses[klassName]
      @debug = ->
        args = getLogMessage logStartValue, _.toArray(arguments)
        for a in args
          console.debug a

        return true
    else
      @debug = -> false

    #set warn logger
    if Logger.isWarn or Logger.warnClasses[klassName]
      @warn = ->
        args = getLogMessage logStartValue, _.toArray(arguments)
        for a in args
          console.warn a if a

        return true
    else
      @warn = -> false

    #set error logger
    if Logger.isError or Logger.errorClasses[klassName]
      @error = ->
        args = getLogMessage logStartValue, _.toArray(arguments)
        for a in args
          console.error a

        return true

      @logError = (message, e) ->
        if _.isFunction(e.log)
          e.log() 
        else
          @error e

        return true
    else
      @error = -> false
      @logError = (e) -> false

  group: ->
    console.group.apply(this, arguments) if console.group

  groupEnd: ->
    console.groupEnd.apply(this, arguments) if console.groupEnd

  getLogMessage = (logStartValue, args) ->
    if args and args.length > 0
      args[0] = logStartValue + args[0]
      return args
    else
      return [ logStartValue ]


  @debugClasses = {}
  @warnClasses = {}
  @logClasses = {}
  @errorClasses = {}

  @getLoggerInstance: (klazz) ->
    Logger.registry = {} if ! Logger.registry

    return Logger.registry[klazz] if !Logger.registry[klazz]
    return Logger.registry[klazz] = new Logger(klazz)


  @resetLogger: () ->
    Logger.debugClasses = {}
    Logger.warnClasses = {}
    Logger.logClasses = {}
    Logger.errorClasses = {}

  @setupLogger: (loggerConfig) ->
    Logger.registry = {}
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

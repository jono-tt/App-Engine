class Logger
  constructor: (klass) ->
    @klass = klass
    @klassName = klass.constructor.getName()

  log: () ->
    if console.isLog
      args = getLogMessage @klassName, _.toArray(arguments)
      console.log.apply(@klass, args)

  debug: () ->
    if console.isDebug
      args = getLogMessage @klassName, _.toArray(arguments)
      console.debug.apply(@klass, args)

  warn: () ->
    if console.isWarn
      args = getLogMessage @klassName, _.toArray(arguments)
      console.warn.apply(@klass, args)

  error: () ->
    if console.isError
      args = getLogMessage @klassName, _.toArray(arguments)
      console.error.apply(@klass, args)

  getLogMessage = (klassName, args) ->
    if args and args.length > 0
      args[0] = "#{klassName}: " + args[0]
      return args
    else
      return [ "#{klassName}: " ]

  
#<< AppEngine/Helpers/Logger

class Error extends Error
  logger = new AppEngine.Helpers.Logger(@)

  constructor: (message, innerError, errorObject) ->
    #apply all to this apply
    _.defaults(@, innerError)

    @message = message
    @innerError = innerError
    @errorObject = errorObject

  getRootError: ->
    return @innerError.getRootError() if @innerError instanceof AppEngine.Helpers.Error
    return @innerError if @innerError
    @

  _log = ->
    if @innerError instanceof AppEngine.Helpers.Error
      _log.call(@innerError)
    else if @innerError
      @logger.group "Error: #{@innerError.message}"

    @logger.log "#{@message}"
    if(@errorObject)
      @logger.log @errorObject

  log: ->
    _log.call(this)

    if @logger.isDebug
      @logger.group "Stack"
      @logger.debug @getRootError().stack
      @logger.groupEnd()
      @logger.groupEnd()

  toString: ->
    return @message + "\n" + @innerError.toString() if @innerError instanceof AppEngine.Helpers.Error
    return @message + "\n" + @innerError


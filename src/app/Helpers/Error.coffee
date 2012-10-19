class Error extends Error

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
      console.group "Error: #{@innerError.message}"

    console.log "#{@message}"
    if(@errorObject)
      console.log @errorObject

  log: ->
    _log.call(this)

    if console.isDebug
      console.group "Stack"
      console.debug @getRootError().stack
      console.groupEnd()
      console.groupEnd()

  toString: ->
    return @message + "\n" + @innerError.toString() if @innerError instanceof AppEngine.Helpers.Error
    return @message + "\n" + @innerError


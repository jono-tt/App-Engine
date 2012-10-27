#<< AppEngine/Objects/Object

###
Extended Error class that contains nested error messages
that can be logged out as a stack

@example How to generate an custom error
  throw new AppEngine.Helpers.Error("Some custome error message", new Error("Original error"))
###

class Error extends AppEngine.Objects.Object
  ###
  Construct a new Error.
  
  @param message {String} custom error message
  @param innerError {Error} the original message that was caught
  @param errorObject {Object} optional as the object that caused the error
  ###
  logger = null;
  constructor: (message, innerError, errorObject) ->
    #apply all to this apply
    _.defaults(@, innerError)

    @message = message
    @innerError = innerError
    @errorObject = errorObject

    super()
    logger = @logger

  ###
  Get the root causing Error object
  
  @return {Error}{AppEngine.Helpers.Error} can return either type as a root cause
  ###
  getRootError: ->
    return @innerError.getRootError() if @innerError instanceof AppEngine.Helpers.Error
    return @innerError if @innerError
    @

  ###
  @private
  ###
  _log = ->
    if @innerError instanceof AppEngine.Helpers.Error
      _log.call(@innerError)
    else if @innerError
      logger.group "Error: #{@innerError.message}"

    logger.log "#{@message}"
    if(@errorObject)
      logger.log @errorObject

  ###
  Write the full error stack out to the console
  ###
  log: ->
    _log.call(this)
    
    logger.group "Stack"
    logger.debug @getRootError().stack
    logger.groupEnd()
    logger.groupEnd()
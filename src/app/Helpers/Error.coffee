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
  @param error {Error} the original error that was caught
  @param errorObject {Object} optional as the object that caused the error
  ###
  logger = null;
  constructor: (message, error, errorObject) ->
    #apply all to this apply
    _.defaults(@, error)
    @message = error.message
    @stack = error.stack if error.stack
    @trace = error.trace if error.trace
    @errorObject = errorObject if errorObject

    #push error messages onto the inner error stack
    if error instanceof AppEngine.Helpers.Error  
      @innerErrors = _.clone(error.innerErrors)
      @innerErrors.push message
    else 
      @innerErrors = [message]

    super()
    logger = @logger

  ###
  Write the full error stack out to the console
  ###
  log: ->
    logger.group "Error: #{@message}"
    logger.log @

    for m in @innerErrors
      logger.log m

    if(@errorObject)
      logger.group "Object That Caused Error"  
      logger.log @errorObject
      logger.groupEnd()
    
    logger.group "Stack"
    logger.debug @stack
    logger.groupEnd()
    logger.groupEnd()

jasmine.Matchers.prototype.toThrow = (expected) ->
  result = false
  exception

  if typeof this.actual != 'function'
    throw new Error 'Actual is not a function'

  try
    @actual()
  catch e
    exception = e;

  if (exception)
    result = (expected == jasmine.undefined || this.env.equals_(exception.message || exception, expected.message || expected))

    if !result
      if exception instanceof AppEngine.Helpers.Error
        expectedMessage = expected.message
        if exception.innerErrors
          if _.contains exception.innerErrors, expectedMessage
            result = true


  _not = @isNot ? "not " : "";

  @message = ->
    if (exception && (expected == jasmine.undefined || !this.env.equals_(exception.message || exception, expected.message || expected)))
      errorMessage = expected ? expected.message || expected : 'an exception'
      actualErrorMessage = (exception.message || exception)
      return "Expected function #{_not} to throw #{errorMessage}, but it threw #{actualErrorMessage}"
    else
      return "Expected function to throw an exception."

  return result

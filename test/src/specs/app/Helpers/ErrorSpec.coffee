describe "Error specs", ->
  finalError = undefined
  m = "Error Caught Level"
  e = new Error("Original Problem")
  originalProblemObj = "this caused an error"

  beforeEach ->
    try
      throw new AppEngine.Helpers.Error("#{m} 1", e, originalProblemObj)
    catch e
      try
        throw new AppEngine.Helpers.Error("#{m} 2", e)
      catch e
        try
          throw new AppEngine.Helpers.Error("#{m} 3", e)
        catch e
          finalError = e

  it "should have the correct specific error when nested", ->
    expect(finalError).toBeDefined()
    expect(finalError.message).toEqual("Original Problem")

  it "should console log correctly", ->
    log = spyOn(finalError.logger, "log")
    finalError.log()

    #check all log messages
    expect(log).toHaveBeenCalled()
    expect(log.calls.length).toEqual(5)
    calls = log.calls
    expect(calls[0].args[0]).toEqual finalError
    expect(calls[1].args[0]).toEqual "#{m} 1"
    expect(calls[2].args[0]).toEqual "#{m} 2"
    expect(calls[3].args[0]).toEqual "#{m} 3"
    expect(calls[4].args[0]).toEqual originalProblemObj
    
  it "should console debug correctly", ->
    debug = spyOn(finalError.logger, "debug")
    finalError.log()
    expect(debug).toHaveBeenCalledWith(finalError.stack)

  it "should console Group correctly", ->
    group = spyOn(finalError.logger, "group")
    groupEnd = spyOn(finalError.logger, "groupEnd")
    finalError.log()

    expect(group).toHaveBeenCalled()
    expect(group.calls[0].args[0]).toEqual "Error: Original Problem"
    expect(group.calls[1].args[0]).toEqual "Object That Caused Error"
    expect(group.calls[2].args[0]).toEqual "Stack"

    expect(groupEnd).toHaveBeenCalled()
    expect(groupEnd.calls.length).toEqual 3


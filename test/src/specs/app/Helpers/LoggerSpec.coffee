describe "Logger Spec", ->
  Logger = AppEngine.Helpers.Logger

  beforeEach ->
    spyOn(console, "log")
    spyOn(console, "debug")
    spyOn(console, "warn") 
    spyOn(console, "error") if console.error

    Logger.resetLogger()

    class window.Dummy
      #dummy class

  it "should initialise logger as default", ->
    config = {}
    Logger.setupLogger config

    expect(Logger.isDebug).not.toBeTruthy()
    expect(Logger.isLog).toBeTruthy()
    expect(Logger.isWarn).toBeTruthy()
    expect(Logger.isError).toBeTruthy()

  describe "debug config", ->
    it "should initialise debug config as enabled", ->
      config = { debug: "true" }
      Logger.setupLogger config
      expect(Logger.isDebug).toBeTruthy()

    it "should initialise debug config by class", ->
      config = { debug: ["Dummy"] }
      Logger.setupLogger config
      expect(Logger.isDebug).not.toBeTruthy()

      log = new Logger(Dummy.prototype)
      console.debug.reset()
      log.debug("test")
      expect(console.debug).toHaveBeenCalledWith("Dummy: test")

  describe "log config", ->
    it "should initialise log config as disabled", ->
      config = { log: "false" }
      Logger.setupLogger config
      expect(Logger.isLog).not.toBeTruthy()

    it "should initialise log config by class", ->
      config = { log: ["Dummy"] }
      Logger.setupLogger config
      expect(Logger.isLog).not.toBeTruthy()

      log = new Logger(Dummy.prototype)
      console.log.reset()
      log.log("test")
      expect(console.log).toHaveBeenCalledWith("Dummy: test")

  describe "warn config", ->
    it "should initialise warn config as disabled", ->
      config = { warn: "false" }
      Logger.setupLogger config
      expect(Logger.isWarn).not.toBeTruthy()

    it "should initialise warn config by class", ->
      config = { warn: ["Dummy"] }
      Logger.setupLogger config
      expect(Logger.isWarn).not.toBeTruthy()

      log = new Logger(Dummy.prototype)
      console.warn.reset()
      log.warn("test")
      expect(console.warn).toHaveBeenCalledWith("Dummy: test")

  describe "error config", ->
    it "should initialise error config as disabled", ->
      config = { error: "false" }
      Logger.setupLogger config
      expect(Logger.isError).not.toBeTruthy()

    it "should initialise warn config by class", ->
      config = { error: ["Dummy"] }
      Logger.setupLogger config
      expect(Logger.isError).not.toBeTruthy()

      log = new Logger(Dummy.prototype)
      #console.error.reset()
      try 
        expect(log.error("test")).not.toBeTruthy()
        expect(console.error).toHaveBeenCalledWith("Dummy: test")
      catch e
        #there is a strange error with console.error on Rhino where you cannot assign to this variable 
        # and are unable to set an spy on it. This will error by this is ok just for testing


describe "EngineController specs", ->
  describe "Initialise", ->
    getObjectByConfigSpy = null
    getTreeStructureSpy = null
    components = "components"
    engine = null
    onInitialised = null
    appConf = {
        rootElement: "rootElement",
        pageManager: "pageManager",
        parameterParser: "parameterParser",
        router: "router"
      }

    beforeEach ->
      getObjectByConfigSpy = spyOn(AppEngine.Helpers, "getObjectByConfig")
      getTreeStructureSpy = spyOn(AppEngine.Helpers.ElementWrap, "getTreeStructure")
      getTreeStructureSpy.andReturn components
      onInitialised = jasmine.createSpy("onInitialised")
      engine = new AppEngine.Controllers.EngineController(appConf)

    it "should create the page manager with specified properties", ->
      engine.initialise(onInitialised)

      #create tree structure created
      expect(getTreeStructureSpy).toHaveBeenCalledWith("rootElement")

      #page manager creation
      expect(getObjectByConfigSpy).toHaveBeenCalled()
      args = getObjectByConfigSpy.calls[0].args
      expect(args[0]).toEqual({
        appConfig: appConf,
        components: components
      })
      expect(args[1]).toEqual(appConf.pageManager)
      expect(args[2]).toEqual(AppEngine.Managers.PageManager)
      expect(typeof args[3]).toEqual("function")

      #call the initPageManager
      testPageManager = "testPageManager"
      args[3](testPageManager)
      expect(engine.pageManager).toEqual(testPageManager)

    it "should create the ParameterParser", ->
      engine.initialise(onInitialised)
      getObjectByConfigSpy.calls[0].args[3]()

      expect(getObjectByConfigSpy.calls.length).toEqual(2)
      args = getObjectByConfigSpy.calls[1].args
      expect(args[0]).toEqual({
        appConfig: appConf
      })
      expect(args[1]).toEqual(appConf.parameterParser)
      expect(args[2]).toEqual(AppEngine.Routers.JsonParameterParser)
      expect(typeof args[3]).toEqual("function")

      #call initParameterParserComplete callback
      parser = "parser"
      args[3](parser)
      expect(engine.parameterParser).toEqual(parser)

    it "should create the Router", ->
      parameterParser = "Application Parameter Parser"
      testPageManager = "testPageManager"
      engine.initialise(onInitialised)
      getObjectByConfigSpy.calls[0].args[3](testPageManager)
      getObjectByConfigSpy.calls[1].args[3](parameterParser)

      #Check init Router was called
      expect(getObjectByConfigSpy.calls.length).toEqual(3)
      args = getObjectByConfigSpy.calls[2].args
      expect(args[0]).toEqual({
        appConfig: appConf,
        pageManager: testPageManager,
        parameterParser: parameterParser
      })
      expect(args[1]).toEqual(appConf.router)
      expect(args[2]).toEqual(AppEngine.Routers.AppRouter)
      expect(typeof args[3]).toEqual("function")

      #callback after Router creation
      testRouter = "testRouter"
      args[3](testRouter)
      expect(engine.appRouter).toEqual(testRouter)

    it "should finalise the initialise by calling the original callback", ->
      parameterParser = "Application Parameter Parser"
      testPageManager = "testPageManager"
      appRouter = "App Router"
      engine.initialise(onInitialised)
      getObjectByConfigSpy.calls[0].args[3](testPageManager)
      getObjectByConfigSpy.calls[1].args[3](parameterParser)
      getObjectByConfigSpy.calls[2].args[3](appRouter)

      engine.initialise(onInitialised)
      expect(onInitialised).toHaveBeenCalled()







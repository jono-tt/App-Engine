#<< AppEngine/Behaviours

describe "AppEngineComponent Specs", ->
  AppEngineComponent = AppEngine.Components.AppEngineComponent

  Behaviours.expectRequiredParameters(AppEngine.Components.AppEngineComponent, ["wrappedElement"])

  describe "New AppEngineComponent", ->
    it "should be an abstract class", ->
      try
        new AppEngineComponent()
        expect("This should error").toEqual("here")
      catch e
        expect(e instanceof AppEngine.Helpers.Error).toBeTruthy()
        expect(e.getRootError().message).toEqual("Unable to create instance of Abstract class 'AppEngineComponent'")

    it "should fail without the correct parameters on creation", ->
      class A extends AppEngineComponent
      try
        new A()
        expect("This should error").toEqual("here")
      catch e
        expect(e instanceof AppEngine.Helpers.Error).toBeTruthy()
        expect(e.getRootError().message).toEqual("The constructor expects the parameter 'el' to be passed in as a config parameter")

    it "should create an object using the correct parameters", ->
      class A extends AppEngineComponent
      new A({el: "1", wrappedElement: "2"})


  describe "Initialise", ->
    class A extends AppEngineComponent
    config = {el: "1", wrappedElement: {}}
    asyncCallEachSpy = null
    callback = null

    beforeEach ->
      asyncCallEachSpy = spyOn(AppEngine.Helpers, "asyncCallEach")
      callback = jasmine.createSpy("callback")

    it "should initialise correctly when it does not have children", ->
      comp = new A(config)

      comp.initialise(callback)

      expect(callback).toHaveBeenCalled()
      expect(asyncCallEachSpy).not.toHaveBeenCalled()

    it "should error when there are children but no addChild method", ->
      config.wrappedElement.children = [1,2,3]
      comp = new A(config)

      expect(->
        comp.initialise(callback)
      ).toThrow(new Error "A: does not support children")

      #also error if addChild is not a function
      comp.addChild = {}
      expect(->
        comp.initialise(callback)
      ).toThrow(new Error "A: does not support children")

    it "should initialise when there are children but and a addChild method", ->
      config.wrappedElement.children = [1,2,3]
      comp = new A(config)
      comp.addChild = jasmine.createSpy("addChild")

      comp.initialise(callback)

      expect(asyncCallEachSpy).toHaveBeenCalled()

      args = asyncCallEachSpy.calls[0].args
      expect(args[0]).toEqual config.wrappedElement.children

      #args[1] = addChild
      args[1]()
      expect(comp.addChild).toHaveBeenCalled()

      #args[2] = complete
      args[2]()
      expect(callback).toHaveBeenCalled()
  
  describe "Dispose", ->
    class A extends AppEngineComponent
    config = {el: "1", wrappedElement: {}}

    it "should trigger the 'dispose' event and then remove all listening children", ->
      comp = new A(config)

      onDispose = jasmine.createSpy("onDispose")
      comp.on("dispose", onDispose)

      comp.dispose()
      expect(onDispose).toHaveBeenCalled()

      #after the first dispose 'comp' should have removed the listeners
      comp.dispose()
      expect(onDispose.calls.length).toEqual(1)


    it "should dispose all children", ->
      comp = new A(config)
      dispose = jasmine.createSpy("dispose")
      comp.children = [ { dispose: dispose }, { dispose: [] } ]

      comp.dispose()
      expect(dispose).toHaveBeenCalled()

      expect(comp.children).not.toBeDefined()
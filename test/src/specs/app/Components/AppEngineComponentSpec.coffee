#<< AppEngine/Behaviours

describe "AppEngineComponent Specs", ->
  AppEngineComponent = AppEngine.Components.AppEngineComponent

  Behaviours.expectRequiredParameters(AppEngineComponent, ["wrappedElement"])
  Behaviours.expectAbstract(AppEngineComponent)

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
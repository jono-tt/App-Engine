describe "ComponentRegistrySpec", ->
  describe "Registry Initialise", ->
    beforeEach ->
      AppEngine.componentRegistry = {}

    it "should fail when a component short name has an error", ->
      class BrokenComponent extends AppEngine.Components.AppEngineComponent
        @getShortNameIdentification: -> throw new Error("Problem with component short name")

      ComponentPack = {}
      ComponentPack.BrokenComponent = BrokenComponent

      expect(->
        AppEngine.initialiseComponentRegistry([ComponentPack])
      ).toThrow(new Error("Cannot get the correct IdentificationClass for the component: 'BrokenComponent'"))


    it "should not add a component when the component does not has a short name", ->
      class BrokenComponent extends AppEngine.Components.AppEngineComponent
        #this is a dummy component

      ComponentPack = {}
      ComponentPack.BrokenComponent = BrokenComponent
      expect(_.toArray(AppEngine.componentRegistry).length).toEqual(0)


    it "should initialise with the correct Components in the registry", ->
      class DummyComponent1 extends AppEngine.Components.AppEngineComponent
        #this is a dummy component
        @getShortNameIdentification: -> "comp1"

      class DummyComponent2 extends AppEngine.Components.AppEngineComponent
        #this is a dummy component
        @getShortNameIdentification: -> "comp2"

      ComponentPack = {}
      ComponentPack.DummyComponent1 = DummyComponent1
      ComponentPack.DummyComponent2 = DummyComponent2

      AppEngine.initialiseComponentRegistry([ComponentPack])

      expect(_.toArray(AppEngine.componentRegistry).length).toEqual(2)
      expect(AppEngine.registryGetTypeFromTypeShortName("comp1")).toEqual(DummyComponent1)
      expect(AppEngine.registryGetTypeFromTypeShortName("comp2")).toEqual(DummyComponent2)

    it "should not register a component that doesn't have a short name", ->
      class NoShortNameComponent extends AppEngine.Components.AppEngineComponent
        #this is a dummy component
        @getShortNameIdentification: -> null

      ComponentPack = {}
      ComponentPack.NoShortNameComponent = NoShortNameComponent
      AppEngine.initialiseComponentRegistry([ComponentPack])
      
      expect(_.toArray(AppEngine.componentRegistry).length).toEqual(0)

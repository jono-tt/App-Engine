#<< AppEngine/Behaviours
#<< AppEngine/Mocks/MockPageManager

describe "Page specs", ->
  Page = AppEngine.Components.Page
  Behaviours.expectRequiredParameters(AppEngine.Components.Page, ["id", "pageManager", "transitionHandler"])

  pageManager = null
  pageEl = null
  page = null

  beforeEach ->
    AppEngine.initialiseComponentRegistry({})

    class TestComponent
      constructor: jasmine.createSpy("TestComponent: constructor")

    AppEngine.registerComponent("TestComponent", TestComponent)
    pageManager = new MockPageManager()
    pageEl = $j("<div id='test_page'> <div name='child1' data-type='TestComponent'/> </div>")

    page = new Page({
        id: "test_page",
        pageManager: pageManager,
        transitionHandler: {},
        el: pageEl,
        wrappedElement: {
          children: [ { 
            name: "child1",
            el: pageEl.find("[name='child1']") 
          }]
        }
      })

  describe "Initialise", ->
    it "should initialise with one component", ->
      pageManager.getPageElementsFromComponents.andReturn([])

      onInit = jasmine.createSpy("onInit")
      page.initialise(onInit)

      expect(onInit).toHaveBeenCalled()
      expect(page.childPageManager).not.toBeDefined()
      expect(page.children.length).toEqual(1)

    it "should initialise with ChildPageManager created", ->
      childPageComponents = [{
        childPageComponent: "Child Page Component"
      }]
      pageManager.getPageElementsFromComponents.andReturn(childPageComponents)

      page.initialise(->)
      expect(page.childPageManager).toBeDefined()
      expect(page.childPageManager.initialise).toHaveBeenCalled()
      expect(page.childPageManager.components).toEqual(childPageComponents)
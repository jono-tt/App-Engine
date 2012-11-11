class MockPageManager

  constructor: () ->
    spyObj = jasmine.createSpyObj("pageManager", ["isPageComponent", "addGlobalComponent", "getPageElementsFromComponents", "getPageAndParamsFromList", "beforeCurrentPageHide", "dispose"])
    _.extend(@, spyObj)

    spyOn(@, "getChildPageManager").andCallThrough()
    spyOn(@, "initialise").andCallThrough()
    @getPageElementsFromComponents.andReturn []

    @__id = "MockPageManager__" + (Math.ceil(Math.random() * 1000))
    @components = []


  initialise: (cb) ->
    cb()

  getChildPageManager: () ->
    @childPageManager = new MockPageManager() if ! @childPageManager

    return @childPageManager

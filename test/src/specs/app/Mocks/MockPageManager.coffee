class MockPageManager
  components: []

  constructor: () ->
    spyObj = jasmine.createSpyObj("pageManager", ["isPageComponent", "getPageElementsFromComponents"])
    _.extend(@, spyObj)

    spyOn(@, "getChildPageManager").andCallThrough()
    spyOn(@, "initialise").andCallThrough()


  initialise: (cb) ->
    cb()

  getChildPageManager: () ->
    @childPageManager = new MockPageManager() if ! @childPageManager

    return @childPageManager
class MockJQueryObject
  constructor: (options) ->
    options = options or {}
    @attributes = options.attributes or {}
    @data = options.data or {}

    spyOn(@, 'attr').andCallThrough()
    spyOn(@, 'find')
    spyOn(@, 'closest')
    spyOn(@, 'append').andCallThrough()
    spyOn(@, 'html').andCallThrough()
    spyOn(@, 'children').andCallThrough()
    spyOn(@, 'addClass').andCallThrough()
    spyOn(@, 'removeClass').andCallThrough()

  attr: (name) ->
    return @attributes[name]
  
  setAttr: (name, value) ->
    @attributes[name] = value
  
  data: (name) ->
    return @data[name]
  
  setData: (name, value) ->
    @data[name] = value

  html: (value) ->
    if(_.isUndefined(value))
      return @htmlData
    else 
      @htmlData = value
  
  addClass: () ->

  removeClass: () ->

  append: (html) ->
    if @htmlData
      @htmlData += html 
    else
      @htmlData = html

  children: () ->
    if !@childrenArray
      firstChild = new MockJQueryObject()

      @childrenArray = [firstChild]
      @childrenArray.first = jasmine.createSpy("first")
      @childrenArray.first.andReturn(firstChild)

      @childrenArray.last = jasmine.createSpy("last")
      @childrenArray.last.andReturn(firstChild)

    return @childrenArray

  setChildren: (children) ->
    @childrenArray = children
    firstChild = new MockJQueryObject()

    @childrenArray = [firstChild]
    @childrenArray.first = jasmine.createSpy("first")
    @childrenArray.first.andReturn(firstChild)

    @childrenArray.last = jasmine.createSpy("last")
    @childrenArray.last.andReturn(firstChild)


  find: (selector) ->

  closest: (element) ->

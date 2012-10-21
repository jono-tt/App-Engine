class MockJQueryObject
  constructor: (options) ->
    options = options or {}
    @attributes = options.attributes or {}
    @_data = options.data or {}

    spyOn(@, 'attr').andCallThrough()
    spyOn(@, 'removeAttr').andCallThrough()
    spyOn(@, 'find')
    spyOn(@, 'closest')
    spyOn(@, 'append').andCallThrough()
    spyOn(@, 'html').andCallThrough()
    spyOn(@, 'children').andCallThrough()
    spyOn(@, 'addClass').andCallThrough()
    spyOn(@, 'removeClass').andCallThrough()
    spyOn(@, 'fadeIn').andCallThrough()
    spyOn(@, 'fadeOut').andCallThrough()
    spyOn(@, 'css').andCallThrough()

  attr: (name) ->
    return @attributes[name]

  removeAttr: (name) ->
    delete @attributes[name]
  
  setAttr: (name, value) ->
    @attributes[name] = value
  
  data: (name) ->
    if name
      return @_data[name]
    else
      return @_data
  
  setData: (name, value) ->
    @_data[name] = value

  html: (value) ->
    if(_.isUndefined(value))
      return @htmlData
    else 
      @htmlData = value
  
  addClass: () ->

  removeClass: () ->

  css: (style) ->
    if @style
      @style = style
    else
      return @style or ''

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

  fadeIn: (duration, cb) ->
    cb()

  fadeOut: (duration, cb) ->
    cb()

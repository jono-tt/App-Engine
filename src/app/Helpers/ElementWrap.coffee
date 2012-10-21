class ElementWrap
  constructor: (el, parent) ->
    @el = el
    @parent = parent
    @children = []

  createTree = (parent, components) ->
    if components.length > 0
      #there are still components to sort into a tree
      comp = $j(components[0])

      if comp.closest(parent.el).length > 0
        #if this parent is the parent of
        components.shift()
        wrap = new AppEngine.Helpers.ElementWrap comp, parent
        parent.children.push(wrap)
        createTree wrap, components
      else
        createTree parent.parent, components

  @getTreeStructure: (startElement) ->
    traversalStart = startElement or $j.find('body')
    startElement = startElement or $j

    components = startElement.find '.ae-comp'
    root = new AppEngine.Helpers.ElementWrap traversalStart
    createTree root, _.toArray components

    #cleanup the root element
    _.each root.children, (c) ->
      delete c.parent

    return root.children
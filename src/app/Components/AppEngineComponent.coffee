#<< AppEngine/Objects/JQueryObject

class AppEngineComponent extends AppEngine.Objects.JQueryObject
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['wrappedElement'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['wrappedElement', 'scope'])
  @isAbstract: -> @ == AppEngineComponent

  constructor: (options = {}) ->
    super(options)

  initialise: (cb) ->
    if @wrappedElement.children and @wrappedElement.children.length > 0
      complete = ->
        if console.isDebug
          console.debug "#{@constructor.getName()}: complete creating children for:"
          console.debug @el

        cb()

      if _.isFunction(@addChild)
        if console.isDebug
          console.debug "#{@constructor.getName()}: creating #{@wrappedElement.children.length} children for:"
          console.debug @el

        AppEngine.Helpers.asyncCallEach @wrappedElement.children, @addChild.createDelegate(@), complete.createDelegate(this)
      else
        throw new Error "#{@constructor.getName()}: does not support children"

    else 
      if console.isDebug
        console.debug "#{@constructor.getName()}: does not contain children:"
        console.debug @el
        
      cb()

  dispose: () ->
    @trigger "dispose", @
    @off()

    if @children
      @logger.debug "Dispose: Start disposing children"
      for child in @children
        child.dispose() if _.isFunction(child.dispose)

      @logger.debug "Dispose: Complete disposing children"
      delete @children
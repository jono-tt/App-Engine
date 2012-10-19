#<< AppEngine/Objects/JQueryObject

class AppEngineComponent extends AppEngine.Objects.JQueryObject
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['wrappedElement'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['wrappedElement'])
  @isAbstract: -> @ == AppEngineComponent

  @getShortNameIdentification: ->
    throw new Error "The Short Name Identification has not been specified for the component '#{@getName()}'"


  constructor: (config) ->
    super(config)

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
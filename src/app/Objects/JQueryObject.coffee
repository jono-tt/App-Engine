#<< AppEngine/Objects/StrictObject

class JQueryObject extends AppEngine.Objects.StrictObject
  @expectedParameters = AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['el'])
  @applyParameters = AppEngine.Helpers.mergeArrays(_super.applyParameters, ['el'])

  @isAbstract: -> @ == JQueryObject

  constructor: (config) ->
    try
      super config
    catch e
      throw new AppEngine.Helpers.Error "#{@constructor.getName()}: Creating new instance '#{config.id}'", e

    @applyConfig @el

  applyConfig: (el, config) ->
    _.each el.data(), (value, name) ->
      @applyConfigAttrib name, value
    , @

  applyConfigAttrib: (name, attribValue) ->
    @[name] = attribValue
